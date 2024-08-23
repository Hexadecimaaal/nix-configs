{ pkgs, ... }: {
  environment.systemPackages = with pkgs; with kdePackages; [
    appmenu-gtk3-module
    filelight
    ark
    # bismuth
    kfind
    kio-extras
    kio-gdrive
    # latte-dock
    kaccounts-providers
    kaccounts-integration
    signond
    # gsignond
    # gsignondPlugins.oauth
    # qoauth
    qtvirtualkeyboard
    calendarsupport
    plasma-thunderbolt
    qt6.qtwebengine
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
  services.xserver = {
    enable = true;

    # displayManager.defaultSession = "plasmawayland";
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.dconf.enable = true;

  programs.kdeconnect.enable = true;
}
