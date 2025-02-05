{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.supportedFilesystems = [ "zfs" "ntfs" "f2fs" ];
  boot.tmp.useTmpfs = true;

  boot.zfs.devNodes = "/dev/disk/by-id";
  networking.hostId = "249ab6f0";
  boot.zfs.requestEncryptionCredentials = [ "Plain" ];
  fileSystems =
    let
      zfs = (dev: {
        device = dev;
        fsType = "zfs";
        options = [ "zfsutil" "X-mount.mkdir" ];
        neededForBoot = true;
      });
    in
    {
      "/boot" = {
        device = "/dev/disk/by-uuid/DD6D-CCA8";
        fsType = "vfat";
      };
      "/" = zfs "Plain/salt/ROOT";
      "/nix" = zfs "Plain/salt/NIX";
      "/home" = zfs "Plain/home";
      "/Plain/Games" = zfs "Plain/Games";
      "/Plain/Downloads" = zfs "Plain/Downloads";
      "/Plain/Videos" = zfs "Plain/Videos";
      "/Plain/home" = {
        device = "/home";
        options = [ "bind" ];
      };
    };


  swapDevices = [{
    device = "/dev/disk/by-partuuid/444d443c-1172-4991-82b9-b1007bb22e91";
    randomEncryption = {
      enable = true;
    };
  }];

  # services.zfs.autoSnapshot.enable = true;
  services.sanoid.enable = true;
  services.sanoid.interval = "*:0/15";
  services.sanoid.datasets =
    let
      template_backups = {
        daily = 7;
        weekly = 4;
        monthly = 12;
        yearly = 10;
        autoprune = true;
        autosnap = false;
        recursive = true;
      };
      template_local = {
        frequently = 12;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
        yearly = 10;
        autosnap = true;
        autoprune = true;
      };
      template_shortlived = {
        frequently = 12;
        hourly = 24;
        daily = 7;
        weekly = 4;
        autosnap = true;
        autoprune = true;
      };
    in
    {
      "Plain/backups" = template_backups;
      "Plain/home" = template_local;
      "Plain/Videos" = template_local;
      "Plain/salt/ROOT" = template_local;
      "Plain/Downloads" = template_shortlived;
      "Plain/Games" = template_shortlived;
    };

  services.syncoid.enable = true;
  services.syncoid.localSourceAllow = [
    "bookmark"
    "hold"
    "send"
    "snapshot"
    "mount"
    "destroy"
  ];
  services.syncoid.localTargetAllow = [
    "change-key"
    "compression"
    "create"
    "mount"
    "mountpoint"
    "receive"
    "rollback"
    "destroy"
  ];

}
