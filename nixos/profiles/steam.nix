{
  programs.steam.enable = true;
  networking.firewall.allowedTCPPorts = [ 27036 27037 27040 ];
  networking.firewall.allowedUDPPorts = [ 27031 27032 27033 27034 27035 27036 ];
}
