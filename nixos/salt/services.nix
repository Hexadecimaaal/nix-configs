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
  services.pykms = {
    enable = true;
    openFirewallPort = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 25510 25515 25516 ];
  networking.firewall.allowedUDPPorts = [ 80 443 25510 25515 25516 ];

  systemd.services."gallery-dl-hourly" = mkgallery-dl {
    urlfile = "/Plain/Videos/windows 更新补丁/!!rip!!/00_download_urls.txt";
    oncalendar = "*:45";
  };

  systemd.services."gallery-dl-daily" = mkgallery-dl {
    urlfile = "/Plain/Videos/windows 更新补丁/!!rip!!/__qd_download_urls.txt";
    oncalendar = "3:45";
  };

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
          proxyPass = "http://10.16.0.5:20001";
        };
      };
    };
  };

  containers.vpn = {
    extraFlags = [ "--bind-user=torrent" ];
    bindMounts = {
      "/var/lib/qbittorrent" = {
        hostPath = "/var/lib/qbittorrent";
        isReadOnly = false;
      };
      "/Plain/Downloads/!!torrents" = {
        hostPath = "/Plain/Downloads/!!torrents";
        isReadOnly = false;
      };
      "/Plain/Videos" = {
        hostPath = "/Plain/Videos";
        isReadOnly = false;
      };
    };

    config = { pkgs, lib, ... }: {
      imports = [
        ../modules/qbittorrent.nix
      ];

      services.qbittorrent = {
        enable = true;
        port = 20001;
        user = "torrent";
        group = "torrent";
        openFilesLimit = 1048576;
      };

      systemd.services.qbittorrent = {
        wantedBy = lib.mkForce [ "services.target" ];
        requires = [ "pia-vpn.service" ];
        after = [ "pia-vpn.service" ];
      };

      systemd.services.qbittorrent-update = {
        wantedBy = [ "qbittorrent.service" ];
        partOf = [ "qbittorrent.service" ];
        bindsTo = [ "qbittorrent.service" ];
        after = [ "qbittorrent.service" ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "qbittorrent-update"
            ''
              ${pkgs.curl}/bin/curl \
                --retry-connrefused \
                --retry 10 \
                -i -X POST \
                -d "json={\"listen_port\": $(cat /root/pia-port)}" \
                http://127.0.0.1:20001/api/v2/app/setPreferences
            '';
          Type = "oneshot";
          # NetworkNamespacePath = "/run/netns/vpn";
        };
      };
    };
  };


  containers.mcservers = {
    autoStart = true;
    privateUsers = "pick";
    privateNetwork = true;
    hostAddress = "10.16.0.2";
    localAddress = "10.16.0.3";
    bindMounts."/mcservers:owneridmap" = {
      hostPath = "/Plain/Games/mcservers";
      isReadOnly = false;
    };
    forwardPorts = [
      {
        hostPort = 25510;
      }
      {
        hostPort = 25515;
      }
      {
        hostPort = 25516;
      }
    ];
    config = { pkgs, lib, config, ... }: {
      system.stateVersion = "25.05";

      networking = {
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
        resolvconf.enable = false;
        firewall.enable = false;
      };
      services.resolved.enable = true;

      systemd.services.mc-mkX = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.jdk8}/bin/java -Xmx8192M -jar forge-1.12.2-14.23.5.2860-universal.jar nogui";
          WorkingDirectory = "/mcservers/mkX";
        };
      };

      systemd.services.mc-mkXV = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.jdk17}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt nogui";
          WorkingDirectory = "/mcservers/mkXV";
        };
      };

      systemd.services.mc-mkXVI = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.jdk8}/bin/java -jar minecraft_server.1.7.10.jar -o false nogui";
          WorkingDirectory = "/mcservers/mkXVI";
        };
      };
    };
  };
}
