{ pkgs, ... }: {
  home.packages = with pkgs; [
    cockatrice
    prismlauncher
    # lutris
    # heroic
    # (pkgs.dwarf-fortress-packages.dwarf-fortress-full.override {
    #   # theme = null;
    #   # enableIntro = false;
    #   # enableFPS = true;
    #   # # enableTWBT = false;
    #   # # enableTextMode = true;
    #   # enableTruetype = false;
    # })
  ];
}
