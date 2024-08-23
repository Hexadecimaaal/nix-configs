{ lib, pkgs, ... }: {

  nix = {
    envVars = { "all_proxy" = "http://192.168.1.1:8080"; };
    binaryCaches = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://dram.cachix.org"
    ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "dram.cachix.org-1:baoy1SXpwYdKbqdTbfKGTKauDDeDlHhUpC+QuuILEMY="
    ];
    trustedUsers = [ "root" "@staff" ];

    gc = {
      automatic = true;
      user = "root";
      options = "--delete-older-than 8d";
    };

    package = pkgs.nix-dram;

    extraOptions =
      let flakesEmpty = pkgs.writeText "flakes-empty.json" (builtins.toJSON { flakes = []; version = 2; });
      in ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
        flake-registry = ${flakesEmpty}
        builders-use-substitutes = true
        auto-optimise-store = true
        default-flake = git+file:///Users/hex/nix-configs
      '';

    nixPath = [ "nixpkgs=/Users/hex/nix-configs" ];
  };

  # nixpkgs.config = {
  #   allowUnfree = true;
  #   oraclejdk.accept_license = true;
  # };

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    gawk curl wget gnupg openssh netcat
  ];

  homebrew = {
    enable = true;
    brews = [ "libtool" ];
    cleanup = "uninstall";
  };

}
