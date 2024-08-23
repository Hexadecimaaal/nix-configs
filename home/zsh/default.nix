{ config, lib, pkgs, ... }:
with lib; let
  aliases = let exa = "${pkgs.eza}/bin/eza"; in {
    l = "${exa} -F auto --icons";
    ls = "${exa} -F auto";
    ll = "${exa} -F auto -lHM --group --time-style=long-iso";
    lsl = "${exa} -F auto -lM --group --icons";
    la = "${exa} -F auto -a";
    lt = "${exa} -F auto -TM -L7";
    lla = "${exa} -F auto -alHM --group --time-style=long-iso";
  };
in
{

  programs.htop.enable = true;

  programs.bat.enable = true;
  programs.eza = {
    enable = true;
    # enableAliases = true;
  };

  home.sessionVariables = {
    EXA_COLORS = "ur=37:uw=37:ux=37:ue=37:gr=37:gw=37:gx=37:tr=37:tw=37:tx=37";
    # LC_ALL = "C";
    FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git'";
    FZF_DEFAULT_OPTS = "--border";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = aliases;
    history = {
      ignorePatterns = [
        "rm *"
        "cd"
        "cd *"
        "l *"
        "ls *"
        "ll *"
        "la *"
        "lla *"
        "lt *"
        "l"
        "ls"
        "ll"
        "la"
        "lla"
        "lt"
        "pwd"
        "exit"
        ".##"
        "jobs"
        "mount"
        "df *"
        "df"
        "false"
        "true"
        "doas -s"
        "htop"
        "top"
        "emacs"
        "fg"
        "bg"
        "git rm *"
        "cat"
        "cat *"
        "bat *"
      ];
      extended = true;
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "65599411ec83505a091f68489617316dec355510";
          sha256 = "sha256-kOwS7WsdVly8CKJqIIKl1XhMPTR9nqqSvvj56Wt3Vmo=";
        };
        file = "powerlevel10k.zsh-theme";
      }
      {
        name = "enhancd";
        file = "init.sh";
        src = pkgs.fetchFromGitHub {
          owner = "b4b4r07";
          repo = "enhancd";
          rev = "v2.2.4";
          sha256 = "sha256-9/JGJgfAjXLIioCo3gtzCXJdcmECy6s59Oj0uVOfuuo=";
        };
      }
      {
        name = "fzf-tab-completion";
        file = "zsh/fzf-zsh-completion.sh";
        src = pkgs.fetchFromGitHub {
          owner = "duganchen";
          repo = "fzf-tab-completion";
          rev = "edbccc266319c9216bba0446471f76215629b5f0";
          sha256 = "sha256-y5qYErwqo4+OZ4odTAevJW5gd2oIHHcMqdHI/ZUR5Pw=";
        };
      }
    ];
    completionInit = "autoload -U compinit && compinit -u";
    initExtra = concatStringsSep "\n" [
      (readFile ./p10k.zsh)
      (readFile ./nixenv.zsh)
      (readFile ./key-bindings.zsh)
    ];
  };

  home.packages = with pkgs; [
    ripgrep
    zip
    unzip
    nix-zsh-completions
    jq
    nixpkgs-fmt
    lsof
    file
    dig
  ];
}
