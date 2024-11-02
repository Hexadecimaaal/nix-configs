{ pkgs, lib, inputs, config, ... }:
# let
#   collectFlakeInputs = input:
#     [ input ] ++ lib.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
# in
{
  # system.extraDependencies = collectFlakeInputs inputs.self;
  nix = {
    channel.enable = false;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    package = pkgs.nix-dram;

    settings =
      let flakesEmpty = pkgs.writeText "flakes-empty.json" (builtins.toJSON { flakes = [ ]; version = 2; });
      in {
        substituters = lib.mkBefore [ "https://cache.iog.io" ];
        trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
        trusted-users = [ "root" "@wheel" ];
        keep-outputs = true;
        keep-derivations = true;
        experimental-features = [ "nix-command" "flakes" ];
        flake-registry = flakesEmpty;
        builders-use-substitutes = true;
        # max-jobs = 2;
        # cores = 16;
        auto-optimise-store = true;
        default-flake = "github:Hexadecimaaal/nix-configs";
        environment = [ "https_proxy" ];
      };

    nixPath = [ "nixpkgs=/home/hex/nix-configs" ];
  };

  systemd.services.nix-gc.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
    MemorySwapMax = 0;
  };

  # nixpkgs.config = {
  #   allowUnfree = true;
  #   oraclejdk.accept_license = true;
  # };
}
