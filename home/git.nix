{ lib, config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Hex";
    userEmail = "me@hexade.ca";

    signing = {
      # signByDefault = true;
      key = "294FB76AC11A1566";
    };

    ignores = [
      "*~"
      "\\#*\\#"
      "auto-save-list"
      "tramp"
      ".\\#*"
      ".org-id-locations"
      "*_archive"
      "._*"

      ".directory"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"

      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"

      ".envrc"
      ".direnv"
    ];

    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "unstable";
      core = {
        bigFileThreshold = "4M";
        eol = "lf";
        autocrlf = "input";
        safecrlf = true;
        whitespace = "trailing-space,space-before-tab,tab-in-indent,tabwidth=2";
      };
      diff.renames = "copy";
      advice = {
        statusHints = false;
        detachedHead = false;
      };
      branch.autoSetupRebase = "always";
      fetch = {
        prune = true;
        pruneTags = true;
        parallel = 0;
        writeCommitGraph = true;
      };
      log = {
        showRoot = true;
        showSignature = true;
      };
      merge = {
        ff = "only";
        # verifySignatures = true;
        autoStash = true;
      };
      pack.threads = 0;
      push = {
        recurseSubmodules = "on-demand";
        negotiate = true;
      };
      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
        abbreviateCommands = true;
      };
      rerere.enabled = true;
      status = {
        short = true;
        branch = true;
        aheadBehind = true;
        showStash = true;
        submoduleSummary = true;
      };
      tag = {
        gpgSign = true;
      };
    };

    lfs.enable = true;

    # difftastic = {
    #   enable = true;
    #   background = "dark";
    #   color = "auto";
    # };
  };
}
