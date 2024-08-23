{ pkgs, lib, ... }:
let
  udevpkgs = with pkgs; [
    (writeTextFile {
      name = "udev-sg3-symlink";
      destination = "/etc/udev/rules.d/61-scsi-symlink.rules";
      text = ''
        # SCSI-ID symlinks for sg3_utils, modified by hex

        ACTION=="remove", GOTO="sg3_utils_symlink_end"

        SUBSYSTEM!="block", GOTO="sg3_utils_symlink_end"
        ENV{UDEV_DISABLE_PERSISTENT_STORAGE_RULES_FLAG}=="1", GOTO="sg3_utils_symlink_end"

        # Enable or disable possibly ambiguous SCSI device symlinks under /dev/disk/by-id
        #
        # .SCSI_SYMLINK_SRC can be any combination of the letter "TLVS":
        #   T: T10 vendor ID ("1...") from VPD 0x83
        #   L: NAA local ("33...") from VPD 0x83
        #   V: vendor-specific ("0...") from VPD 0x83
        #   S: vendor/model/serial number ("S...") from VPD 0x80
        # Symlinks will be created for every letter included in .SCSI_SYMLINK_SRC.
        # Symlinks for NAA (except "local") and EUI-64 IDs (see below) are always created.
        #
        # NOTE: The default rules in 60-persistent-storage.rules create a symlink
        # "ENV{ID_BUS}-ENV{ID_SERIAL}" symlink anyway, where ID_BUS is "scsi", "ata", "usb", or "cciss".
        # ID_SERIAL is set in 55-scsi-sg3_id.rules from the least ambiguous device identifier.
        # The symlinks created by this file are created *in addition* to the default symlink.
        #
        # This only needs to be changed if some subsystem, like dm-crypt or LVM, depends on the
        # additional symlinks being present for device identification.
        #

        # 0: vpd page 0x80 identifier
        ENV{ID_SCSI_SERIAL}=="?*", ENV{DEVTYPE}=="disk", \
            SYMLINK+="disk/by-id/scsi-1$env{ID_VENDOR}_$env{ID_MODEL}_$env{ID_SCSI_SERIAL}"
        ENV{ID_SCSI_SERIAL}=="?*", ENV{DEVTYPE}=="partition", \
            SYMLINK+="disk/by-id/scsi-1$env{ID_VENDOR}_$env{ID_MODEL}_$env{ID_SCSI_SERIAL}-part%n"

        # 6: T10 Vendor identifier (prefix 1)
        # ENV{.SCSI_SYMLINK_SRC}=="*T*", ENV{SCSI_IDENT_LUN_T10}=="?*", ENV{DEVTYPE}=="disk", \
        #     SYMLINK+="disk/by-id/scsi-1$env{SCSI_IDENT_LUN_T10}"
        # ENV{.SCSI_SYMLINK_SRC}=="*T*", ENV{SCSI_IDENT_LUN_T10}=="?*", ENV{DEVTYPE}=="partition", \
        #     SYMLINK+="disk/by-id/scsi-1$env{SCSI_IDENT_LUN_T10}-part%n"

        # 8: Vendor-specific identifier (prefix 0)
        # ENV{SCSI_IDENT_LUN_VENDOR}=="?*", ENV{DEVTYPE}=="disk", \
        #     SYMLINK+="disk/by-id/scsi-0$env{ID_VENDOR}_$env{ID_MODEL}_$env{SCSI_IDENT_LUN_VENDOR}"
        # ENV{SCSI_IDENT_LUN_VENDOR}=="?*", ENV{DEVTYPE}=="partition", \
        #     SYMLINK+="disk/by-id/scsi-0$env{ID_VENDOR}_$env{ID_MODEL}_$env{SCSI_IDENT_LUN_VENDOR}-part%n"

        LABEL="sg3_utils_symlink_end"
      '';
    })
  ];
  udevpath = with pkgs; [
    # sg3_utils
  ];
in
{
  imports = [
    ./elecom-deft.nix
    ./canokey.nix
    ./orbit-fusion.nix
    ./hp4x.nix
    ./keyboards.nix
    ./bluetooth.nix
  ];
  programs.adb.enable = true;
  services.udev.packages = udevpkgs;
  services.udev.path = udevpath;
  boot.initrd.services.udev.packages = udevpkgs;
  boot.initrd.services.udev.binPackages = udevpath;
  hardware.logitech.wireless.enable = true;
  environment.systemPackages = with pkgs; [
    solaar
  ];
}
