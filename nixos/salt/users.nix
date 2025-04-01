{ config, pkgs, ... }: {
  sops.secrets.hex_passhash.neededForUsers = true;
  users.users = {
    "hex" = {
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
      ];
    };
    "omeg" = {
      uid = 1001;
      group = "omeg";
      isNormalUser = true;
      extraGroups = [ "users" ];
    };
    "oxa" = {
      uid = 1004;
      group = "oxa";
      isNormalUser = true;
      extraGroups = [ "wheel" "users" ];
    };
    "dram" = {
      uid = 1005;
      group = "dram";
      isNormalUser = true;
      extraGroups = [ "wheel" "users" ];
    };

    "torrent" = {
      uid = 994;
      group = "torrent";
      home = "/var/lib/qbittorrent";
      createHome = true;
    };
  };
  users.groups = {
    "hex".gid = 1000;
    "omeg".gid = 1001;
    "oxa".gid = 1004;
    "dram".gid = 1005;
    "torrent".gid = 994;
  };
}
