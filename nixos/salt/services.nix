{ pkgs, ... }:
let
  mkgallery-dl = { urlfile, oncalendar }: {
    after = [ "network.target" ];
    description = "gallery-dl a list at ${oncalendar}";
    path = with pkgs; [ gallery-dl attr ffmpeg ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.gallery-dl}/bin/gallery-dl --abort 20 -i "${urlfile}"
      '';
      User = "hex";
      Group = "users";
      UMask = "0002";
      LimitNOFILE = 4096;
    };
    startAt = oncalendar;
  };
in
{
  imports = [
    ../modules/qbittorrent.nix
  ];
  services.pykms = {
    enable = true;
    openFirewallPort = true;
  };
  services.qbittorrent = {
    enable = true;
    port = 20001;
    user = "torrent";
    group = "users";
    openFilesLimit = 1048576;
  };
  networking.firewall.allowedTCPPorts = [ 80 443 25510 25515 ];
  networking.firewall.allowedUDPPorts = [ 80 443 25510 25515 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "hexadecimaaal@gmail.com";
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "torrent.salt.lan.hexade.ca" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.0.1.1:20001";
        };
      };
    };
  };

  systemd.services."gallery-dl-hourly" = mkgallery-dl {
    urlfile = "/Plain/Videos/windows 更新补丁/!!rip!!/00_download_urls.txt";
    oncalendar = "*:45";
  };

  systemd.services."gallery-dl-daily" = mkgallery-dl {
    urlfile = "/Plain/Videos/windows 更新补丁/!!rip!!/__qd_download_urls.txt";
    oncalendar = "3:45";
  };

  systemd.services.qbittorrent = {
    requires = [ "pia-vpn.service" "netns-vpn.service" ];
    after = [ "pia-vpn.service" "netns-vpn.service" ];
    serviceConfig = {
      MemoryAccounting = true;
      MemoryHigh = "8G";
      NetworkNamespacePath = "/run/netns/vpn";
    };
  };

  systemd.services.qbittorrent-update = {
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "update-qbittorrent.sh" ''
        sleep 10
        ${pkgs.curl}/bin/curl -i -X POST -d "json={\"listen_port\": $(cat /root/pia-port)}" http://127.0.0.1:20001/api/v2/app/setPreferences
      '';
      Type = "oneshot";
      NetworkNamespacePath = "/run/netns/vpn";
    };
  };

  systemd.services.mc-mkX = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.jdk8}/bin/java -Xmx8192M -jar forge-1.12.2-14.23.5.2860-universal.jar nogui";
      WorkingDirectory = "/Plain/Games/mcservers/mkX";
      User = "hex";
      Group = "hex";
    };
  };

  systemd.services.mc-mkXV = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.jdk17}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt nogui";
      WorkingDirectory = "/Plain/Games/mcservers/mkXV";
      User = "hex";
      Group = "hex";
    };
  };
}
