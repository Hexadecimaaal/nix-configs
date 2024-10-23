{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    unifont
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    source-han-serif
    # liberation_ttf
  ];

  fonts.enableDefaultPackages = false;
  fonts.fontDir.enable = true;

  # fonts.fontconfig = {
  #   enable = true;
  #   antialias = false;
  # };

}
