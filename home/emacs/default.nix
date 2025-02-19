{ lib, config, pkgs, ... }: {
  imports = [
  #  ./ligature.nix
  ];
  programs.emacs = {
    enable = true;
    package = pkgs.emacsNativeComp;

    extraPackages = epkgs: with epkgs; [
      sudo-edit
      undo-tree
      undohist
      unfill
      parinfer-rust-mode
      auto-indent-mode

      use-package

      yaml-mode
      # lean-mode
      racket-mode
      nix-haskell-mode
      json-mode
      nix-mode
      rust-mode
      haskell-mode
      markdown-mode
      web-mode

      ligature
      telephone-line
      ample-theme
    ];

    # overrides = self: super: {
    #   inherit (self.melpaStablePackages) use-package;
    #   ligature = super.trivialBuild {
    #     pname = "ligature";
    #     version = "not really";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "mickeynp";
    #       repo = "ligature.el";
    #       rev = "9357156a917a021a87b33ee391567a5d8e44794a";
    #       sha256 = "sha256-Bgb5wFyx0hMilpihxA8cTrRVw71EBOw2DczlM4lSNMs=";
    #     };
    #   };
    # };
  };

  home.file.".emacs.d" = {
    source = ./config;
    recursive = true;
  };

  programs.zsh.initExtra = ''
    e() {
      if [ -n "$*" ]; then
        emacsclient --alternate-editor= --display="$DISPLAY" "$@";
      else
        emacsclient --alternate-editor= --create-frame;
      fi
    }
  '';

  home.sessionVariables.EDITOR = ''emacsclient --alternate-editor= --display="$DISPLAY"'';
}
