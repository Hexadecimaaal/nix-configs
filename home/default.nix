{ pkgs, lib, ... }: {
  imports = [
    ./development
    ./emacs
    ./zsh
    ./direnv.nix
    ./git.nix
    ./less.nix
    ./rime
    ./ssh.nix
    ./tmux.nix
  ];
  programs.home-manager.enable = true;

  home.packages = with pkgs; [ deploy-rs sops ];
}
