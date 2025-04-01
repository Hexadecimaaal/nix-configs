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
    internalInterfaces = [ "ve-*" "docker*" "virbr*" "veth0" ];
  };


  systemd.network = {
    enable = true;
    netdevs."10-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
      extraConfig = ''
        [Bridge]
        STP=yes
      '';
    };
    netdevs."10-veth0" = {
      netdevConfig = {
        Kind = "veth";
        Name = "veth0";
      };
      extraConfig = ''
        [Peer]
        Name = vpeer0
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
        "20-ve" = {
          matchConfig.Name = "ve-*";
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
        "40-veth0" = {
          matchConfig.Name = "veth0";
          linkConfig.RequiredForOnline = "no";
          linkConfig.Unmanaged = "no";
          linkConfig.ActivationPolicy = "up";
          networkConfig = {
            DHCP = "no";
            Address = "10.16.0.4/31";
          };
        };
      };
  };

  networking.resolvconf.enable = false;
  services.resolved = {
    enable = true;
    fallbackDns = [ ];
  };

  sops.secrets.pia_env = {
    mode = "0444";
  };

  containers.vpn = {
    autoStart = true;
    privateUsers = "pick";
    privateNetwork = true;
    interfaces = [ "vpeer0" ];
    enableTun = true;
    bindMounts = {
      "/root/pia_env" = {
        hostPath = "${config.sops.secrets.pia_env.path}";
        isReadOnly = true;
      };
    };
    config = { config, pkgs, ... }: {
      system.stateVersion = "25.05";

      networking = {
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
        resolvconf.enable = false;
        firewall.enable = false;
      };
      services.resolved.enable = true;

      systemd.network = {
        enable = true;
        networks = {
          "30-vpeer0" = {
            matchConfig.Name = "vpeer0";
            linkConfig.RequiredForOnline = "routable";
            networkConfig = {
              Address = "10.16.0.5/31";
              Gateway = "10.16.0.4";
            };
          };
        };
      };

      systemd.targets."services" = {
        after = [ "multi-user.target" "network-online.target" ];
        wants = [ "network-online.target" ];
      };

      systemd.services."start-services" = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "systemctl --no-block start services.target";
          Type = "oneshot";
        };
      };

      systemd.services."pia-vpn" = {

        wantedBy = [ "services.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];

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
                --cacert "/root/ca.rsa.4096.crt" \
                --data-urlencode "pubkey=$pubkey" \
                --data-urlencode "pt=$token" \
                "https://$PIA_HOST:1337/addKey" )
              ${wg-quick} down pia
              mkdir -p /etc/wireguard
              echo "
              [Interface]
              PrivateKey = $privkey
              Address = $(echo $wireguard_json | jq -r '.peer_ip')
              PostUp = resolvectl dns pia $(echo $wireguard_json | jq -r '.dns_servers[0]')
              PostDown = resolvectl revert pia
              [Peer]
              PublicKey = $(echo $wireguard_json | jq -r '.server_key')
              Endpoint = $PIA_SERVER:$(echo $wireguard_json | jq -r '.server_port')
              AllowedIPs = 0.0.0.0/0
              PersistentKeepalive = 25
              " > /etc/wireguard/pia.conf || exit 1
              ${wg-quick} up pia || exit 1
              payload_and_signature=$(curl -s -G -m 5 \
                --connect-to "$PIA_HOST::$PIA_SERVER:" \
                --cacert "/root/ca.rsa.4096.crt" \
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
                  --cacert "/root/ca.rsa.4096.crt" \
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
            EnvironmentFile = "/root/pia_env";
            Restart = "always";
            ExecStopPost = "${wg-quick} down pia";
            # NetworkNamespacePath = "/run/netns/vpn";
          };
      };
    };
  };
}
