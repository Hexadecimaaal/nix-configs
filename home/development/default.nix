{ pkgs, ... }: {
  imports = [
    ./coq.nix
    ./agda.nix
  ];
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   oraclejdk.accept_license = true;
  # };

  programs.java.enable = true;
  programs.java.package = pkgs.jdk8;
  home.packages = with pkgs; [
    (lib.hiPrio j)
    # (dyalog.override { acceptLicense = true; })
  ];
}
