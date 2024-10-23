{ pkgs, ... }: {
  home.packages = with pkgs; [
    easyeffects
    ardour calf # cadence
    yabridge yabridgectl
    bitwig-studio
    surge surge-XT cardinal fire
    # tunefish
    lsp-plugins
  ];
}
