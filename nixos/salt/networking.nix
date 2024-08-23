{ lib, pkgs, config, ... }: {
  imports = [
    # ../profiles/cgproxy.nix
    # ../profiles/v2ray.nix
  ];
  networking.hostId = "249ab6f0";
  networking.hostName = "salt";

  networking.useDHCP = false;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 64331 ];
  networking.firewall.allowedUDPPorts = [ 64331 ];
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
          };
        };
      };
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
        ExecStart = pkgs.writeShellScript "start-${netns}-netns.sh" ''
          ${ip} netns add ${netns}
          ${ip} -n ${netns} link set lo up
          ${ip} link add ${veth} type veth peer name ${vpeer}
          ${ip} link set ${vpeer} netns ${netns}
          ${ip} link set ${veth} up
          ${ip} -n ${netns} link set ${vpeer} up
          ${ip} addr add ${vethip-cidr} dev ${veth}
          ${ip} -n ${netns} addr add ${vpeerip} dev ${vpeer}
          ${ip} -n ${netns} route add default via ${vethip}
        '';
        ExecStop = pkgs.writeShellScript "stop-${netns}-netns.sh" ''
          ${ip} netns del ${netns}
        '';
      };
    };

  systemd.services."ivacy-vpn" = {

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "netns-vpn.service" ];
    bindsTo = [ "netns-vpn.service" ];
    partOf = [ "netns-vpn.service" ];

    path = [ pkgs.iptables pkgs.iproute2 pkgs.nettools ];
    serviceConfig = {
      ExecStart = "@${pkgs.openvpn}/sbin/openvpn openvpn --suppress-timestamps --config /root/OpenVPN-Configs/Turkey-UDP.ovpn";
      WorkingDirectory = "/root/OpenVPN-Configs";
      Restart = "always";
      ExecStopPost = "@${pkgs.iproute2}/bin/ip ip route add default via 10.0.1.0";
      Type = "notify";
      NetworkNamespacePath = "/run/netns/vpn";
    };
  };
}
