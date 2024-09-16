{ pkgs, ... }: {
  imports = [
    ./vscode.nix
    ./rust.nix
    ./c.nix
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

    (python3.withPackages (p: with p; [
      ipykernel
      pip
      scipy
      numpy
      matplotlib
      ipywidgets
      # pygame
      z3
      notebook
      jupyter-client
      pyzmq
    ]))
  ];
}
