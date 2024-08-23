{
  programs.tmux = {
    enable = true;
    clock24 = true;
    historyLimit = 100000;
    mouse = true;
    newSession = true;
    terminal = "xterm-256color";
    escapeTime = 0;
    extraConfig = ''
      set-window-option -g xterm-keys on

      # Emacs key bindings in tmux command prompt (prefix + :) are better than
      # vi keys, even for vim users
      set -g status-keys emacs

      # Focus events enabled for terminals that support them
      set -g focus-events on

      # Super useful when using "grouped sessions" and multi-monitor setup
      setw -g aggressive-resize on

      # Easier and faster switching between next/prev window
      bind C-p previous-window
      bind C-n next-window

      bind C-b send-prefix
      bind b last-window
    '';
  };
}
