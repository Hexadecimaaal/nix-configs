{ pkgs, ... }: {
  home.packages = with pkgs; [
    eagle kicad # freecad
  ];
}
