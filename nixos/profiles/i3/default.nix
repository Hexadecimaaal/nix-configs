{ pkgs, lib, ... }: {
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3.overrideAttrs (oldAttrs: rec {
      pname = "i3-vertical";
      version = "next";

      src = pkgs.fetchFromGitHub {
        owner = "arash-rohani";
        repo = "i3-vertical";
        rev = "f1b71af897ed5f345fb12fb2eca6ed5641be9811";
        sha256 = "sha256-9bzPnPbzAJOEKOPC95wnkx1ry2cDQD3iq8A6df6wRVI=";
      };

      buildInputs = oldAttrs.buildInputs ++ [ pkgs.pcre2 ];
    });
    extraPackages = with pkgs; [
      # dmenu i3status betterlockscreen polybarFull rofi
      feh
    ];
  };
  services.picom = {
    enable = true;
    # experimentalBackends = true;
    fade = true;
    fadeDelta = 3;
    fadeSteps = [ 0.03 0.03 ];
    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
      "class_g = 'firefox' && argb"
      "class_g = 'thunderbird' && argb"
      "class_g = 'TelegramDesktop' && argb"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    ];
    opacityRules = [
      "95:class_g = 'URxvt' && !_NET_WM_STATE@:32a"
      "0:_NET_WM_STATE@[0]:32a *= '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[1]:32a *= '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[2]:32a *= '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[3]:32a *= '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[4]:32a *= '_NET_WM_STATE_HIDDEN'"
    ];
    settings = {
      shadow-radius = 7;

      blur-method = "dual_kawase";
      blur-deviation = true;
      blur-strength = 7;
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
        "class_g = 'firefox' && argb"
        "class_g = 'thunderbird' && argb"
        "class_g = 'TelegramDesktop' && argb"
        "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
      ];
    };
    backend = "glx";
    vSync = true;
    wintypes = {
      dock = { shadow = false; clip-shadow-above = true; };
      dnd = { shadow = false; };
    };
  };
  # services.xserver.desktopManager.plasma5.runUsingSystemd = false;
  # services.xserver.displayManager.sessionCommands = "export KDEWM=i3";
}
