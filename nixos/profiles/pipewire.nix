{ pkgs, lib, ... }: {
  # Enable sound.
  # sound.enable = true;

  security.pam.loginLimits = lib.mkAfter [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio" ; type = "-"; value = "99"       ; }
    { domain = "@audio"; item = "priority"; type = "-"; value = "-15"     ; }
  ];

  services.udev.extraRules = lib.mkAfter ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';

  users.extraGroups = lib.mkAfter { audio = {}; };

  boot.kernelParams = [ "snd_hda_intel.power_save=0" ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # environment.etc."pipewire/pipewire.conf.d/default.conf".text = builtins.toJSON {
  #   "context.properties" = {
  #     # "default.clock.rate" = 48000;
  #     # "default.clock.quantum" = 64;
  #   };

  #   "context.modules" = [
  #     {
  #       name = "libpipewire-module-rtkit";
  #       args = {
  #         "nice.level" = -15;
  #         "rt.prio" = 88;
  #         "rt.time.soft" = 200000;
  #         "rt.time.hard" = 200000;
  #       };
  #       flags = [ "ifexists" "nofail" ];
  #     }
  #     {
  #       name = "libpipewire-module-portal";
  #       flags = [ "ifexists" "nofail" ];
  #     }
  #     {
  #       name = "libpipewire-module-access";
  #       args = {};
  #     }
  #   ];
  # };

  # environment.etc."pipewire/pipewire-pulse.conf.d/default.conf".text = builtins.toJSON {
  #   "stream.properties" = {
  #     # "node.latency" = "64/48000";
  #     "resample.quality" = 1;
  #   };

  #   "context.modules" = [
  #     {
  #       name = "libpipewire-module-rtkit";
  #       args = {
  #         "nice.level" = -15;
  #         "rt.prio" = 88;
  #         "rt.time.soft" = 200000;
  #         "rt.time.hard" = 200000;
  #       };
  #       flags = [ "ifexists" "nofail" ];
  #     }
  #   ];
  # };

  security.rtkit.enable = true;

  users.users."hex".extraGroups = [ "rtkit" "jackaudio" "audio" ];

  environment.sessionVariables = {
    DSSI_PATH = "$HOME/.dssi:$HOME/.nix-profile/lib/dssi:/run/current-system/sw/lib/dssi";
    LADSPA_PATH = "$HOME/.ladspa:$HOME/.nix-profile/lib/ladspa:/run/current-system/sw/lib/ladspa";
    LV2_PATH = "$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2";
    LXVST_PATH = "$HOME/.lxvst:$HOME/.nix-profile/lib/lxvst:/run/current-system/sw/lib/lxvst";
    VST_PATH = "$HOME/.vst:$HOME/.nix-profile/lib/vst:/run/current-system/sw/lib/vst";
    XDG_DATA_DIRS = [ "/run/current-system/sw/share/gsettings-schemas/appmenu-gtk3-module-0.7.6" ];
  };
}
