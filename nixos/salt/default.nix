# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, suites, ... }: {
  imports = [
    ./fs.nix
    ./networking.nix
    ./users.nix
    ./plain-share.nix
    ./services.nix
    ./gitlab-runner.nix
    # ../profiles/numa.nix
    # ../profiles/i3
    ../profiles/nix-conf.nix
    ../profiles/k3b.nix
    ../profiles/libvirtd.nix
    ../profiles/auth.nix
    ../profiles/pipewire.nix
    ../profiles/xkeysnail
    ../profiles/hardware
    ../profiles/fontconfig.nix
    ../profiles/i18n.nix
    ../profiles/console.nix
    ../profiles/kde.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  boot.kernel.sysctl."vm.swappiness" = 150;
  systemd.services.zswap = {
    description = "Enable ZSwap";
    wantedBy = [ "basic.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 1 >/sys/module/zswap/parameters/enabled
    '';
  };


  # services.nfs.server.enable = true;

  # nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_6_10;
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "mpt3sas" ];
  boot.kernelModules = [ "kvm-amd" "mlx4_core" "mlx4_en" "mlx4_ib" "vfio-pci" "tcp_bbr" ];

  hardware.enableRedistributableFirmware = true;

  # boot.kernelPatches = [
  #   { name = "add-acs-overrides";
  #     patch = pkgs.fetchurl {
  #       name = "add-acs-overrides.patch";
  #       url = "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio&id=6609cfb7a2c08b930e67d10d246eb05baf3679db";
  #       sha256 = "uQvnt5ZSvmH31QaRAA9qjHWiQNwu7iZnto2YT2dYP3c=";
  #     };
  #   }
  # ];

  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelParams = [
    # "mlx4_core.port_type_array=2"
    # "zfs.zfs_arc_max=17179869184"
    "amd_iommu=on"
    "iommu=pt"
    "kvm.ignore_msrs=1"
    "kvm.report_ignored_msrs=0"
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
  ];

  systemd.targets = {
    "sleep".enable = false;
    "suspend".enable = false;
    "hibernate".enable = false;
    "hybrid-sleep".enable = false;
  };

  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  # time.timeZone = "Asia/Shanghai";


  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.dpi = 192;
  # environment.variables = {
  #   _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2.0";
  # };

  services.upower.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # gnome.gnome-tweaks
    # gnomeExtensions.material-shell
    nfs-utils
    wget
    vim
    emacs
    git
    pciutils
    # ark
    unar
    xz
    firefox
    wineWowPackages.staging
    # xorg.xmodmap
    sanoid
    mbuffer
    lzop
  ];

  # programs.dconf.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # programs.kdeconnect.enable = true;
  programs.steam.enable = true;

  # nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      StreamLocalBindUnlink = true;
    };
  };

  services.flatpak.enable = true;

  # services.teamviewer.enable = true;
  services.zerotierone.enable = true;

  # services.joycond.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
