{ pkgs, ... }: {
  home.packages = with pkgs; [
    coq
  ];
  programs.emacs.extraPackages = epkgs: with epkgs; [
    proof-general
    company-coq
  ];
}
