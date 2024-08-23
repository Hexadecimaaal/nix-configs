{ pkgs, ... }: {
  home.packages = [
    pkgs.agda
  ];
  programs.emacs.extraPackages = epkgs: with epkgs; [
    agda2-mode
  ];
}
