{
  description = "hex nix config";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = [
    "https://nix-community.cachix.org"
    # "https://mirrors.bfsu.edu.cn/nix-channels/store?priority=30"
    "https://dram.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "dram.cachix.org-1:baoy1SXpwYdKbqdTbfKGTKauDDeDlHhUpC+QuuILEMY="
  ];

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixos.url = "github:Hexadecimaaal/nixpkgs/nixos-unstable";
    #nixos.url = "git+file:///home/hex/Documents/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";


    nix-dram.url = "github:dramforever/nix-dram";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixos";

    nur.url = "github:nix-community/NUR";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixos";


    nixpkgs-ancient.url = "github:NixOS/nixpkgs-channels/nixos-15.09";
    nixpkgs-ancient.flake = false;

    nil.url = "github:oxalica/nil";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixos";

    # dyalog-nixos.url = "github:markus1189/dyalog-nixos";
    # dyalog-nixos.inputs.nixpkgs.follows = "nixos";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    oxa-config.url = "github:oxalica/nixos-config/test/invar-kde";
    oxa-config.flake = false;

    deploy-rs.url = "github:serokell/deploy-rs";

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    { self
    , nixos
    , flake-utils
    , nix-dram
    , home
    , nur
    , darwin
    , nixpkgs-ancient
    , nil
      # , dyalog-nixos
    , rust-overlay
    , vscode-server
    , oxa-config
    , deploy-rs
    , sops-nix
    } @ inputs:
    flake-utils.lib.eachDefaultSystem
      (system: {
        legacyPackages = import nixos {
          inherit system;
          config.allowUnfree = true;
          config.oraclejdk.accept_license = true;
          overlays = builtins.attrValues self.overlays ++ [
            nur.overlays.default
            # nix-dram.overlay
          ];
        };
        # packages.home-manager = home.defaultPackage.${system};
      }) //
    (
      let
        genRev = {
          system.configurationRevision = self.rev or null;
          system.nixos.label =
            with builtins;
            if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev
            then "${substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
            else "dirty";
        };
        nixReg = {
          nix.registry = nixos.lib.mapAttrs (key: value: { from = { id = key; type = "indirect"; }; flake = value; }) inputs;
        };
        mkNixos = { mods, system, stateVersion }: nixos.lib.nixosSystem {
          system = system;
          modules = mods ++ [
            { nixpkgs.pkgs = self.legacyPackages.${system}; }
            { system.stateVersion = stateVersion; }
            genRev
            nixReg
            inputs.home.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };
        mkHomeModule = { user, dir, imports, stateVersion }: {
          home-manager.users.${user} = { config, inputs, ... }: {
            inherit imports;
            home.username = user;
            home.homeDirectory = dir;
            home.stateVersion = stateVersion;
          };
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
        };
      in
      {
        overlays = {
          packages = (final: prev: import ./bits/packages.nix final prev);
          tweaks = (final: prev: import ./bits/tweaks.nix final prev);
          rust-overlay = (import rust-overlay);
          pinning = final: prev:
            let
              pkgs-ancient = import nixpkgs-ancient { inherit (final) system; };
            in
            {
              inherit (pkgs-ancient) jre7 jdk7;
              inherit (nil.packages.${final.system}) nil;
              inherit (nix-dram.packages.${final.system}) nix-dram;
              # inherit (dyalog-nixos.packages.${final.system}) ride dyalog;
              # telegram-desktop = final.callPackage (oxa-config + "/pkgs/telegram-desktop-fix-screencast-glitch") { inherit (prev) telegram-desktop; };
            };
        };

        nixosConfigurations.salt = let stateVersion = "22.11"; in mkNixos {
          mods = [
            ./nixos/salt
            (mkHomeModule {
              user = "hex";
              dir = "/home/hex";
              imports = [ vscode-server.homeModules.default ./home ./home/desktop ];
              inherit stateVersion;
            })
          ];
          system = "x86_64-linux";
          inherit stateVersion;
        };
        nixosConfigurations.mercury = let stateVersion = "23.11"; in mkNixos {
          mods = [
            ./nixos/mercury
            (mkHomeModule {
              user = "hex";
              dir = "/home/hex";
              imports = [ vscode-server.homeModules.default ./home ./home/desktop ];
              inherit stateVersion;
            })
          ];
          system = "x86_64-linux";
          inherit stateVersion;
        };
        nixosConfigurations.palladium = let stateVersion = "23.11"; in
          mkNixos {
            mods = [
              ./nixos/palladium
              (mkHomeModule {
                user = "hex";
                dir = "/home/hex";
                imports = [ vscode-server.homeModules.default ./home ./home/desktop ];
                inherit stateVersion;
              })
            ];
            system = "x86_64-linux";
            inherit stateVersion;
          };
        nixosConfigurations.shinonome = let stateVersion = "24.11"; in
          mkNixos {
            mods = [
              ./nixos/shinonome
            ];
            system = "x86_64-linux";
            inherit stateVersion;
          };

        darwinConfigurations.iron = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./darwin/iron
            {
              nixpkgs.system = "x86_64-darwin";
              nixpkgs.overlays = builtins.attrValues self.overlays ++ [
                nur.overlays.default
                nix-dram.overlay
                # emacs-darwin.overlay
              ];
            }
          ];
          #specialArgs = { inherit inputs; };
        };

        # homeConfigurations = {
        #   hex-full = home.lib.homeManagerConfiguration {
        #     pkgs = self.legacyPackages."x86_64-linux";
        #     modules = [
        #       vscode-server.homeModules.default
        #       ./home/desktop
        #       ./home
        #       {
        #         home = {
        #           homeDirectory = "/home/hex";
        #           username = "hex";
        #           stateVersion = "22.05";
        #         };
        #       }
        #     ];
        #   };

        #   hex-nox = home.lib.homeManagerConfiguration {
        #     pkgs = self.legacyPackages."x86_64-linux";
        #     modules = [
        #       vscode-server.homeModules.default
        #       ./home
        #       {
        #         home = {
        #           homeDirectory = "/home/hex";
        #           username = "hex";
        #           stateVersion = "22.05";
        #         };
        #       }
        #     ];
        #   };

        #   hex-darwin = home.lib.homeManagerConfiguration {
        #     pkgs = self.legacyPackages."x86_64-darwin";
        #     modules = [
        #       ./home
        #       {
        #         home = {
        #           homeDirectory = "/Users/hex";
        #           username = "hex";
        #           stateVersion = "22.05";
        #         };
        #       }
        #     ];
        #   };
        # };

        # deploy.sudo = "doas -u";
        # deploy.sshOpts = [ "-t" ];
        deploy.nodes = {
          salt = {
            hostname = "salt.lan.hexade.ca";
            interactiveSudo = false;
            profiles.system = {
              sshUser = "hex";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.salt;
              activationTimeout = 1800;
            };
          };
          palladium = {
            hostname = "palladium.lan.hexade.ca";
            interactiveSudo = true;
            profiles.system = {
              sshUser = "hex";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.palladium;
            };
          };
          shinonome = {
            hostname = "shinonome.hexade.ca";
            interactiveSudo = true;
            profiles.system = {
              sshUser = "hex";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.shinonome;
            };
          };
        };
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      }
    );
}
