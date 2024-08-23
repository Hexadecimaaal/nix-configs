{ lib, pkgs, ... }: {
  services.udev.extraRules = ''
    KERNEL == "uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
    KERNEL=="event[0-9]*", GROUP="uinput", MODE="0660"
  '';

  users.groups.uinput = lib.mkDefault {};

  users.users.hex.extraGroups = [ "uinput" ];

  environment.systemPackages = [ pkgs.xkeysnail ];

  systemd.user.services."xkeysnail" = {
    description = "xkeysnail daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    # after = [ "display-manager.service" ];
    # requires = [ "display-manager.service" ];
    serviceConfig = {
      # Environment = "DISPLAY=:0";
      ExecStartPre= "-${pkgs.xorg.xhost}/bin/xhost +SI:localuser:root";
      ExecStart = "${pkgs.xkeysnail}/bin/xkeysnail --quiet --watch ${./config.py}";
      RestartSec = "5";
      Restart = "always";
    };
    enable = false;
  };
}
