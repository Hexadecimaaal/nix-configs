{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/graphical.nix"
    ./fs.nix
    ../profiles/nix-conf.nix
    ../profiles/auth.nix
    ../profiles/fontconfig.nix
    ../profiles/hardware
    ../profiles/pipewire.nix
  ];

  system.extraDependencies = with pkgs;
    [
      stdenv
      stdenvNoCC # for runCommand
      busybox
      jq # for closureInfo
      # For boot.initrd.systemd
      makeInitrdNGTool
      systemdStage1
      systemdStage1Network
    ];

  # Show all debug messages from the kernel but don't log refused packets
  # because we have the firewall enabled. This makes installs from the
  # console less cumbersome if the machine has a public IP.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  # Prevent installation media from evacuating persistent storage, as their
  # var directory is not persistent and it would thus result in deletion of
  # those entries.
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';

  programs.zsh.enable = true;

  users.users."hex" = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "hex";
    extraGroups = [
      "wheel"
      "users"
      "libvirtd"
      "docker"
      "dialout"
      "networkmanager"
      "cdrom"
      "kvm"
      "adbusers"
      "plugdev"
    ];
  };

  users.groups."hex".gid = 1000;

  networking.networkmanager.enable = true;
  powerManagement.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  virtualisation.vmware.guest.enable = pkgs.stdenv.hostPlatform.isx86;
  virtualisation.hypervGuest.enable = true;
  # services.xe-guest-utilities.enable = pkgs.stdenv.hostPlatform.isx86;
  virtualisation.virtualbox.guest.enable = false;


  boot.supportedFilesystems = [ "zfs" "ntfs" "f2fs" ];

  boot.zfs.devNodes = "/dev/disk/by-partuuid";

  services.zfs.autoSnapshot.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-mozc rime-data ];
  };

  environment.profileRelativeSessionVariables.QT_PLUGIN_PATH = [ "/${pkgs.qt6.qtbase.qtPluginPrefix}" ];

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "all" ];
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "C";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  console = {
    packages = with pkgs; [ powerline-fonts terminus_font ];
    font = "ter-powerline-v24b";
    useXkbConfig = true;
    earlySetup = true;
    colors = [
      "232627"
      "ed1515"
      "11d116"
      "f67400"
      "1d99f3"
      "9b59b6"
      "1abc9c"
      "fcfcfc"
      "7f8c8d"
      "c0392b"
      "1cdc9a"
      "fdbc4b"
      "3daae9"
      "8e44ad"
      "16a085"
      "ffffff"
    ];
  };

  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    appmenu-gtk3-module
    nfs-utils
    wget
    vim
    emacs
    git
    ark
    unar
    xz
    filelight
    firefox
    wineWowPackages.staging
    home-manager
  ];

  hardware.bluetooth.enable = true;
  systemd.services."bluetooth".serviceConfig.ExecStart =
    let
      args = [ "-f" "/etc/bluetooth/main.conf" "-E" ];
    in
    lib.mkOverride 10 [
      ""
      "${config.hardware.bluetooth.package}/libexec/bluetooth/bluetoothd ${lib.escapeShellArgs args}"
    ];

  networking.hostName = "mercury";

  services.colord.enable = true;

  services.power-profiles-daemon.enable = lib.mkForce false;
  # powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  services.tlp.settings = {
    PCIE_ASPM_ON_BAT = "powersupersave";
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PREF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PREF_POLICY_ON_BAT = "balance_power";
    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";
  };

  boot.kernelParams = [ "nvme.noacpi=1" ];

  # system.stateVersion = "23.11";
}
