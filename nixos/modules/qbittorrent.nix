# https://raw.githubusercontent.com/hercules-ci/nixflk/template/modules/services/torrent/qbittorrent.nix

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.qbittorrent;
  configDir = "${cfg.dataDir}/.config";
  openFilesLimit = 4096;
in
{
  options.services.qbittorrent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Run qBittorrent headlessly as systemwide daemon
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    openFilesLimit = mkOption {
      default = openFilesLimit;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.qbittorrent ];

    nixpkgs.overlays = [
      (final: prev: {
        qbittorrent = prev.qbittorrent.override { guiSupport = false; };
      })
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.qbittorrent = {
      after = [ "network.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.qbittorrent ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.qbittorrent}/bin/qbittorrent-nox \
            --profile=${configDir} \
            --webui-port=${toString cfg.port}
        '';
        # To prevent "Quit & shutdown daemon" from working; we want systemd to
        # manage it!
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        LimitNOFILE = cfg.openFilesLimit;
        IOSchedulingPriority = 7;

        PrivateTmp = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ProcSubset = "pid";
        ProtectProc = "invisible";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid" ];
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "qBittorrent Daemon user";
      };
    };

    users.groups =
      mkIf (cfg.group == "qbittorrent") { qbittorrent = { gid = null; }; };
  };
}
