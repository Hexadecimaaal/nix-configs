{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    iptables
    cgproxy
  ];

  systemd.services."cgproxy" = {
    description = "cgproxy Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [
      "systemd-networkd.service"
      "network.target"
      "network-online.target"
    ];
    partOf = [ "systemd-networkd.service" ];

    path = with pkgs; [ util-linux iptables iproute2 coreutils sysctl ];
    serviceConfig = {
      ExecStart = "${pkgs.cgproxy}/bin/cgproxyd --execsnoop";
    };
  };

  systemd.services."restart-cgproxy" = {
    description = "restart cgproxy after wakeup";
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemctl --no-block restart cgproxy.service";
    };
  };
}
