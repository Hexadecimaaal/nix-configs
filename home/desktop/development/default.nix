{ pkgs, ... }: {
  imports = [
    ./vscode.nix
  ];

  services.vscode-server.enable = true;

  home.packages = with pkgs; [
    jetbrains.idea-community
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    (jetbrains.plugins.addPlugins jetbrains.clion [ "github-copilot" ])
    (jetbrains.plugins.addPlugins jetbrains.rust-rover [ "github-copilot" ])
    # jetbrains.mps
    # wolfram-engine
    mathematica
    # ride
    wireshark
  ];
}
