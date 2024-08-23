{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../profiles/console.nix
    ../profiles/nix-conf.nix
    ./fs.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets.hashed_pw.neededForUsers = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  # hardware.enableRedistributableFirmware = true;

  boot.kernelModules = [
    "tcp_bbr"
  ];

  systemd.targets = {
    "sleep".enable = false;
    "suspend".enable = false;
    "hibernate".enable = false;
    "hybrid-sleep".enable = false;
  };

  # security.doas.enable = true;
  # security.sudo.enable = false;
  # environment.systemPackages = with pkgs; [ doas-sudo-shim ];
  # Configure doas
  # security.doas.extraRules = [{
  #   groups = [ "wheel" ];
  #   keepEnv = true;
  #   persist = true;
  #   setEnv = [
  #     "HOME"
  #   ];
  # }];

  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;

  users.users."hex" = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "hex";
    hashedPasswordFile = config.sops.secrets.hashed_pw.path;
    extraGroups = [
      "wheel"
      "users"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzIIn4NUTDp39EamjGpYWKVd25bo8Z5BBCJzIBsmKsG cardno:F1D0_01312E07"
    ];
  };
  users.groups."hex".gid = 1000;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.mtr.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      StreamLocalBindUnlink = true;
    };
  };

  networking.hostName = "shinonome";
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = true;

  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.firewall.logRefusedConnections = lib.mkDefault false;
  networking.firewall.allowedTCPPorts = [ 53 80 443 4950 8080 ];
  networking.firewall.allowedUDPPorts = [ 53 80 443 4950 8080 ];

  users.users."v2ray" = {
    isSystemUser = true;
    group = "v2ray";
  };
  users.groups."v2ray" = { };
  sops.secrets.v2ray_conf.owner = config.users.users."v2ray".name;
  sops.secrets.v2ray_conf.group = config.users.users."v2ray".name;
  systemd.services.v2ray = {
    after = [ "network.target" "nss-lookup.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = config.users.users."v2ray".name;
      ExecStart = "${config.services.v2ray.package}/bin/v2ray run -config ${config.sops.secrets.v2ray_conf.path}";
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
      AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = true;
      Restart = "on-failure";
      RestartPreventExitStatus = 23;
    };
  };

  system.stateVersion = "24.11";
}
