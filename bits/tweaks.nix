self: super: {
  otfcc = super.otfcc.overrideAttrs (old: {
    version = "trunk";

    src = super.fetchFromGitHub {
      owner = "caryll";
      repo = "otfcc";
      rev = "235d1bd6fb81c8daeaa5232aa840c1e37f07fa86";
      sha256 = "sha256-m1qokWf10t2TgamMOKY3eMD/vB7jG0Ic0Ut4YzZR15g=";
    };
  });
  sg3_utils = super.sg3_utils.overrideAttrs (old: {
    dontStrip = true;
  });
  treesheets = super.treesheets.overrideAttrs (old: {
    version = "anton-02169b636fefa3fbc714469938bbbf1a9595a133";
    src = super.fetchFromGitHub {
      owner = "AntonBogun";
      repo = "treesheets";
      rev = "02169b636fefa3fbc714469938bbbf1a9595a133";
      sha256 = "sha256-EBSNgjMlw0ibnmJ1ZmJKyb9HtI+ITr4g6br2x8TgROU=";
    };
  });
  # firefox = super.firefox-bin;
  mathematica = super.mathematica.override {
    version = "13.3.0";
    source = super.requireFile {
      name = "Mathematica_13.3.0_BNDL_LINUX_CN.sh";
      # Get this hash via a command similar to this:
      # nix-store --query --hash \
      # $(nix store add-path Mathematica_XX.X.X_BNDL_LINUX.sh --name 'Mathematica_XX.X.X_BNDL_LINUX.sh')
      sha256 = "sha256:0miwzw40bwh1fngj0nmhp7c02wjv80qwpzc8mlv0x3r9p61piwn7";
      message = ''
        Your override for Mathematica includes a different src for the installer,
        and it is missing.
      '';
      hashMode = "recursive";
    };
  };
}
