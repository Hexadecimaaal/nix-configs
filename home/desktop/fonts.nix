{ pkgs, ... }: {
  # fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # sarasa-gothic
    # iosevka
    fira-code
    fira-code-symbols
    cm_unicode
    i-dot-ming

    # (nerdfonts.override {
    #   fonts = [ "Iosevka" ];
    # })
  ];
}
