{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    firefox
    wineWowPackages.staging
    vlc
    mpv
    # gnome.gnome-tweaks
    # gnomeExtensions.material-shell
    # ark
    # xorg.xmodmap
  ];
}
