{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3ab56ce4-0e7f-435f-aeec-511eaa5a698b";
    fsType = "btrfs";
    options = [ "subvol=@root" "noatime" "compress=zstd:8" ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/3ab56ce4-0e7f-435f-aeec-511eaa5a698b";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress=zstd:8" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3ab56ce4-0e7f-435f-aeec-511eaa5a698b";
    fsType = "btrfs";
    options = [ "subvol=@home" "noatime" "compress=zstd:8" ];
  };
  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/3ab56ce4-0e7f-435f-aeec-511eaa5a698b";
    fsType = "btrfs";
    options = [ "subvol=@swap" "noatime" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ad1361f7-4ab4-4252-ba00-5d4e5d8590fb";
    fsType = "ext3";
  };
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];
}
