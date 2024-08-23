{ lib, ... }: {
  imports = [
    ./development
    ./audio.nix
    ./biblo.nix
    ./engineering.nix
    ./firefox.nix
    ./fonts.nix
    ./games.nix
    ./image.nix
    ./office.nix
    ./messaging.nix
    ./players.nix
    ./torrent.nix
  ];

  home.file.".XCompose".source = ./XCompose;
  home.file.".Xmodmap".source = ./Xmodmap;
}
