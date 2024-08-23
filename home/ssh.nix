{ pkgs, ... }: {
  programs.ssh = {
    matchBlocks = {
      # "github.com" = {
      #   hostname = "github.com";
      #   proxyCommand = "nc -X 5 -x localhost:1080 %h %p";
      # };
    };
  };
}
