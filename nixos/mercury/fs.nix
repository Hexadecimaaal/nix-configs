{ pkgs, ... }: {
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    theme = pkgs.nixos-grub2-theme;
    memtest86.enable = true;
    efiInstallAsRemovable = true;
    extraEntries = ''
      menuentry 'NixOS 23.05.1310.33223d479ff Installer '  --class installer {
        linux /boot/bzImage findiso=/latest-nixos-plasma5-x86_64-linux.iso init=/nix/store/a5hc26cg749kbf525rgpb0y3r1pj5xd4-nixos-system-nixos-23.05.1310.33223d479ff/init  root=LABEL=nixos-plasma5-23.05-x86_64 boot.shell_on_fail video=hyperv_fb:1152x864 elevator=noop nohibernate splash loglevel=4
        initrd /boot/initrd
      }
      menuentry 'NixOS 23.05.1310.33223d479ff Installer (nomodeset)'  --class nomodeset {
        linux /boot/bzImage findiso=/latest-nixos-plasma5-x86_64-linux.iso init=/nix/store/a5hc26cg749kbf525rgpb0y3r1pj5xd4-nixos-system-nixos-23.05.1310.33223d479ff/init  root=LABEL=nixos-plasma5-23.05-x86_64 boot.shell_on_fail video=hyperv_fb:1152x864 elevator=noop nohibernate splash loglevel=4 nomodeset
        initrd /boot/initrd
      }
      menuentry 'NixOS 23.05.1310.33223d479ff Installer (copytoram)'  --class copytoram {
        linux /boot/bzImage findiso=/latest-nixos-plasma5-x86_64-linux.iso init=/nix/store/a5hc26cg749kbf525rgpb0y3r1pj5xd4-nixos-system-nixos-23.05.1310.33223d479ff/init  root=LABEL=nixos-plasma5-23.05-x86_64 boot.shell_on_fail video=hyperv_fb:1152x864 elevator=noop nohibernate splash loglevel=4 copytoram
        initrd /boot/initrd
      }
      menuentry 'NixOS 23.05.1310.33223d479ff Installer (debug)'  --class debug {
        linux /boot/bzImage findiso=/latest-nixos-plasma5-x86_64-linux.iso init=/nix/store/a5hc26cg749kbf525rgpb0y3r1pj5xd4-nixos-system-nixos-23.05.1310.33223d479ff/init  root=LABEL=nixos-plasma5-23.05-x86_64 boot.shell_on_fail video=hyperv_fb:1152x864 elevator=noop nohibernate splash loglevel=4 debug
        initrd /boot/initrd
      }
      menuentry 'rEFInd' --class refind {
        # Force root to be the FAT partition
        # Otherwise it breaks rEFInd's boot
        search --set=root --no-floppy --fs-uuid 33E2-6920
        chainloader ($root)/EFI/boot/refind_x64.efi
      }
    '';
  };

  boot.initrd.luks.devices."mercury".device = "/dev/disk/by-uuid/724f15f3-fa70-4489-aeaa-86536406e4c3";

  fileSystems."/" =
    {
      device = "/dev/mapper/mercury";
      fsType = "btrfs";
      options = [ "subvol=@root" "compress=zstd" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/mapper/mercury";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "relatime" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/mapper/mercury";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "relatime" ];
    };

  fileSystems."/swap" =
    {
      device = "/dev/mapper/mercury";
      fsType = "btrfs";
      options = [ "subvol=@swap" "noatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/33E2-6920";
      fsType = "vfat";
    };
}
