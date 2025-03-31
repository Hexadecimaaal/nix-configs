{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    # package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vadimcn.vscode-lldb
      ms-vscode-remote.remote-ssh
      ms-vsliveshare.vsliveshare
      ms-vscode.cpptools
      ms-python.python
      ms-toolsai.jupyter
      ms-python.vscode-pylance
    ];
  };

  home.packages = with pkgs; [
    nil
    # coqPackages.vscoq-language-server
  ];
}
