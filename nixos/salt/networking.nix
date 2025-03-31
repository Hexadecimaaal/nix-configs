{ lib, pkgs, config, ... }: {
  imports = [
    # ../profiles/cgproxy.nix
    # ../profiles/v2ray.nix
  ];

  networking.hostName = "salt";

  networking.useDHCP = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 64331 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  networking.firewall.logRefusedConnections = false;
  networking.firewall.filterForward = true;

  networking.nat = {
    enable = true;
    externalInterface = "br0";
    internalInterfaces = [ "veth*" "docker*" ];
  };


  systemd.network = {
    enable = true;
    netdevs."20-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
      extraConfig = ''
        [Bridge]
        STP=yes
      '';
    };
    networks =
      let
        enslave = (ifname: brname: {
          matchConfig.Name = ifname;
          networkConfig.Bridge = brname;
          linkConfig.RequiredForOnline = "no";
        });
      in
      {
        "20-ztr" = {
          matchConfig.Name = "ztr*";
          linkConfig.RequiredForOnline = "no";
          linkConfig.Unmanaged = "yes";
        };
        "30-enp4s0" = enslave "enp4s0" "br0";
        "30-enp6s0" = enslave "enp6s0" "br0";
        "30-enp66s0" = enslave "enp66s0" "br0";
        "30-enp66s0d1" = enslave "enp66s0d1" "br0";
        "40-br0" = {
          matchConfig.Name = "br0";
          bridgeConfig = { };
          linkConfig.RequiredForOnline = "routable";
          networkConfig = {
            DHCP = "yes";
            DHCPPrefixDelegation = true;
            IPv6AcceptRA = true;
            DNSSECNegativeTrustAnchors = [ "lan.hexade.ca" ];
            DNSSEC = "yes";
            MulticastDNS = "yes";
          };
        };
      };
  };

  networking.resolvconf.enable = false;
  services.resolved = {
    enable = true;
    fallbackDns = [ ];
  };

  systemd.services."netns-vpn" =
    let
      veth = "veth0";
      vpeer = "vpeer0";
      netns = "vpn";
      vethip = "10.0.1.0";
      vethip-cidr = "10.0.1.0/31";
      vpeerip = "10.0.1.1/31";
      ip = "${pkgs.iproute2}/bin/ip";
    in
    {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      # bindsTo = [ "sys-devices-virtual-net-br0.device" ];
      # after = [ "sys-devices-virtual-net-br0.device" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = [
          "-${ip} netns del ${netns}"
          "-${ip} link del ${veth}"
          "-${ip} link del ${vpeer}"
        ];
        ExecStart = [
          "${ip} netns add ${netns}"
          "${ip} -n ${netns} link set lo up"
          "${ip} link add ${veth} type veth peer name ${vpeer}"
          "-${ip} link set ${vpeer} netns ${netns}"
          "${ip} link set ${veth} up"
          "${ip} -n ${netns} link set ${vpeer} up"
          "${ip} addr add ${vethip-cidr} dev ${veth}"
          "${ip} -n ${netns} addr add ${vpeerip} dev ${vpeer}"
          "${ip} -n ${netns} route add default via ${vethip} dev ${vpeer} onlink"
        ];
        ExecStopPost = [
          "-${ip} link del ${veth}"
          "-${ip} netns del ${netns}"
        ];
      };
    };

  sops.secrets.pia_env = { };
  systemd.services."pia-vpn" = {

    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "netns-vpn.service" ];
    requires = [ "network-online.target" ];
    bindsTo = [ "netns-vpn.service" ];
    partOf = [ "netns-vpn.service" ];

    path = with pkgs; [ jq wireguard-tools curl iproute2 ];
    serviceConfig =
      let
        wg-quick = "${pkgs.wireguard-tools}/bin/wg-quick";
      in
      {
        ExecStart = pkgs.writeShellScript "start-pia.sh" ''
          gentokenResp=$(curl -s -u "$PIA_USER:$PIA_PASS" https://privateinternetaccess.com/gtoken/generateToken)
          if [[ -z "$gentokenResp" ]]; then
            echo "Failed to generate token"
            exit 1
          fi
          if [[ $(echo $gentokenResp | jq -r '.status') != "OK" ]]; then
            echo "Failed to generate token: $(echo $gentokenResp | jq -r '.message')"
            exit 1
          fi
          token=$(echo $gentokenResp | jq -r '.token')
          privkey=$(wg genkey)
          pubkey=$(echo $privkey | wg pubkey)
          wireguard_json=$(curl -s -G \
            --connect-to "$PIA_HOST::$PIA_SERVER:" \
            --cacert "ca.rsa.4096.crt" \
            --data-urlencode "pubkey=$pubkey" \
            --data-urlencode "pt=$token" \
            "https://$PIA_HOST:1337/addKey" )
          ${wg-quick} down pia
          mkdir -p /etc/wireguard
          echo "
          [Interface]
          PrivateKey = $privkey
          Address = $(echo $wireguard_json | jq -r '.peer_ip')
          DNS = $(echo $wireguard_json | jq -r '.dns_servers[0]')
          [Peer]
          PublicKey = $(echo $wireguard_json | jq -r '.server_key')
          Endpoint = $PIA_SERVER:$(echo $wireguard_json | jq -r '.server_port')
          AllowedIPs = 0.0.0.0/0
          PersistentKeepalive = 25
          " > /etc/wireguard/pia.conf || exit 1
          ${wg-quick} up pia || exit 1
          payload_and_signature=$(curl -s -G -m 5 \
            --connect-to "$PIA_HOST::$PIA_SERVER:" \
            --cacert "ca.rsa.4096.crt" \
            --data-urlencode "token=$token" \
            "https://$PIA_HOST:19999/getSignature" )
          if [[ $(echo $payload_and_signature | jq -r '.status') != "OK" ]]; then
            echo "Failed to get signature: $(echo $payload_and_signature | jq -r '.message')"
            exit 1
          fi
          signature=$(echo $payload_and_signature | jq -r '.signature')
          payload=$(echo $payload_and_signature | jq -r '.payload')
          port=$(echo $payload | base64 -d | jq -r '.port')
          echo "$port" > /root/pia-port
          while true; do
            bind_port_response=$(curl -s -G -m 5 \
              --connect-to "$PIA_HOST::$PIA_SERVER:" \
              --cacert "ca.rsa.4096.crt" \
              --data-urlencode "payload=$payload" \
              --data-urlencode "signature=$signature" \
              "https://$PIA_HOST:19999/bindPort" )
            if [[ $(echo $bind_port_response | jq -r '.status') != "OK" ]]; then
              echo "Failed to bind port: $(echo $bind_port_response | jq -r '.message')"
              exit 1
            fi
            sleep 900
          done
        '';
        EnvironmentFile = "${config.sops.secrets.pia_env.path}";
        WorkingDirectory = "/root/manual-connections";
        Restart = "always";
        ExecStopPost = "${wg-quick} down pia";
        NetworkNamespacePath = "/run/netns/vpn";
      };
  };
}
