{ pkgs, ... }: {
  home.packages = with pkgs; [
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
      # vmprof
    ]))
  ];
}
