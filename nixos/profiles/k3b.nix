{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ k3b dvdplusrwtools cdrdao cdrkit ];
  security.wrappers = {
    cdrdao = {
      setuid = true;
      owner = "root";
      group = "cdrom";
      permissions = "u+wrx,g+x";
      source = "${pkgs.cdrdao}/bin/cdrdao";
    };
    cdrecord = {
      setuid = true;
      owner = "root";
      group = "cdrom";
      permissions = "u+wrx,g+x";
      source = "${pkgs.cdrkit}/bin/cdrecord";
    };
  };

    users.users.hex.extraGroups = [ "cdrom" ];
}
