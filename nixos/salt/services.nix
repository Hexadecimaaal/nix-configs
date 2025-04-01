{
  services.pykms = {
    enable = true;
    openFirewallPort = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 25510 25515 25516 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

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
        requires = [ "pia-vpn.service" ];
        after = [ "pia-vpn.service" ];
      };

      systemd.services.qbittorrent-update = {
        wantedBy = [ "qbittorrent.service" ];
        partOf = [ "qbittorrent.service" ];
        bindsTo = [ "qbittorrent.service" ];
        after = [ "qbittorrent.service" ];
        path = with pkgs; [ jq curl ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "qbittorrent-update"
            ''
              port=""
              targetPort=$(cat /root/pia-port)
              while [[ x$port != x$targetPort ]]; do
                echo "setting port to $targetPort"
                curl \
                  --retry-connrefused \
                  --retry 10 \
                  -i -X POST \
                  -d "json={\"listen_port\": $targetPort}" \
                  http://127.0.0.1:20001/api/v2/app/setPreferences
                echo "done POST"
                prefs=$(curl \
                  --retry-connrefused \
                  --retry 10 \
                  http://127.0.0.1:20001/api/v2/app/preferences)
                port=$(echo $prefs | jq -r '.listen_port')
                echo "port now: $port"
              done
              echo "port successfully set to target, exiting"
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

  containers.gallery-dl = {
    autoStart = true;
    privateUsers = "pick";
    privateNetwork = true;
    hostAddress = "10.16.0.6";
    localAddress = "10.16.0.7";
    bindMounts."/Plain/Videos:owneridmap" = {
      hostPath = "/Plain/Videos";
      isReadOnly = false;
    };
    config = { pkgs, lib, ... }: {
      system.stateVersion = "25.05";

      networking = {
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
        resolvconf.enable = false;
        firewall.enable = false;
      };
      services.resolved.enable = true;

      systemd.services."gallery-dl" = {
        after = [ "network.target" ];
        wants = [ "network.target" ];
        description = "gallery-dl a list";
        path = with pkgs; [ gallery-dl attr ffmpeg ];
        serviceConfig = {
          ExecStart = ''
            gallery-dl --abort 20 -c "/Plain/Videos/.gallery-dl.config.json" -i "/Plain/Videos/.urls.txt"
          '';
          UMask = "0002";
          LimitNOFILE = 4096;
        };
        startAt = "3:45";
      };
    };
  };
}
