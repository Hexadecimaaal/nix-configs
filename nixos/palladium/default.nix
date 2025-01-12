{ lib, pkgs, config, ... }: {
  imports = [
    ./fs.nix
    ./powersave.nix
    # ./i915-sriov.nix

    ../profiles/hardware
    ../profiles/auth.nix
    ../profiles/fontconfig.nix
    # ../profiles/k3b.nix
    ../profiles/libvirtd.nix
    ../profiles/nix-conf.nix
    ../profiles/pipewire.nix
    ../profiles/console.nix
    ../profiles/i18n.nix
    ../profiles/kde.nix
    # ../profiles/cgproxy.nix
    # ../profiles/v2ray.nix
    ../profiles/steam.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.initrd.systemd.enable = true;

  programs.mtr.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.hex_passhash.neededForUsers = true;
  users.users."hex" = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "hex";
    hashedPasswordFile = config.sops.secrets.hex_passhash.path;
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
      "audio"
    ];
  };

  users.groups."hex".gid = 1000;

  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;

  networking.hostName = "palladium";
  networking.networkmanager.enable = true;
  # networking.networkmanager.dns = "systemd-resolved";
  networking.useDHCP = false;
  # networking.resolvconf.enable = false;
  # services.resolved.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 64331 ];
  networking.firewall.allowedUDPPorts = [ 64331 ];
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  networking.firewall.logRefusedConnections = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      StreamLocalBindUnlink = true;
    };
  };

  boot.kernel.sysctl."vm.swappiness" = 150;
  # zramSwap.enable = true;
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

  environment.systemPackages = with pkgs; [
    nfs-utils
    wget
    vim
    emacs
    git
    unar
    p7zip
    xz
    firefox
    wineWowPackages.staging
    home-manager
    podman-compose
  ];

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;

  virtualisation.waydroid.enable = true;

  services.flatpak.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # samsung-unified-linux-driver
      # splix
    ];
  };
  programs.steam.enable = true;

  # nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  # services.colord.enable = true;

  services.hardware.bolt.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # services.zerotierone.enable = true;

  # services.postgresql.enable = true;

  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-ocl vaapiIntel ];
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
  hardware.graphics.enable32Bit = true;

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # system.stateVersion = "23.11";
}
