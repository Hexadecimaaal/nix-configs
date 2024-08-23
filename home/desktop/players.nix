{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
    # amarok
    audacious
  ];

  services.mpris-proxy.enable = true;
}
