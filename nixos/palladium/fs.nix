{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.supportedFilesystems = [ "zfs" "ntfs" "f2fs" ];

  networking.hostId = "4cf3a8e1";
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.zfs.requestEncryptionCredentials = [ "palladium" ];

  # services.zfs.autoSnapshot.enable = true;
  environment.systemPackages = with pkgs; [
    sanoid
    lzop
    mbuffer
  ];
  services.sanoid.enable = true;
  services.sanoid.interval = "*:0/15";
  services.sanoid.datasets =
    let
      template = {
        frequently = 12;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
    in
    {
      "palladium" = template;
      "palladium/home" = template;
    };

  # boot.kernelParams = [ "zfs.zfs_dmu_offset_next_sync=0" ];

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
      "/" = zfs "palladium";
      "/nix" = zfs "palladium/nix";
      "/home" = zfs "palladium/home";
      "/boot" = {
        device = "/dev/disk/by-uuid/C8D8-CBA8";
        fsType = "vfat";
      };
    };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/4947bbbf-785f-4d86-8ed6-a921dcf09d3b";
    randomEncryption = {
      enable = true;
    };
  }];
}
