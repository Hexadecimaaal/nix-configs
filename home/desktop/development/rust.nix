{ pkgs, ... }: {
  home.packages = with pkgs; let
    rust = rust-bin.nightly.latest.default.override {
      extensions = [ "rust-src" "llvm-tools-preview" ];
      targets = [ "x86_64-unknown-linux-gnu" "thumbv6m-none-eabi" ];
    };
  in
  [ rust ];
}
