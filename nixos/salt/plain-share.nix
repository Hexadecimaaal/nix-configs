{
  services.samba = {
    enable = true;
    enableNmbd = false;
    openFirewall = true;
    settings = {
      global = {
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
        "client min protocol" = "SMB2";
        "server min protocol" = "NT1";
        "ntlm auth" = "ntlmv1-permitted";
        "vfs objects" = "catia streams_xattr";
        # fruit:aapl = yes
        # fruit:copyfile = yes
        # fruit:model = MacSamba
        "workgroup" = "WORKGROUP";
        "server string" = "%h server (Samba, NixOS uwu)";
        # log file = /var/log/samba/log.%m
        # max log size = 1000
        # logging = file
        # log level = all:2
        # panic action = /usr/share/samba/panic-action %d
        "server role" = "standalone server";
        "obey pam restrictions" = true;
        "unix password sync" = true;
        "passwd program" = "/usr/bin/passwd %u";
        "passwd chat" = "*Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .";
        "pam password change" = true;
        "username map script" = "/bin/echo";
        "read raw" = true;
        "write raw" = true;
        "server signing" = false;
        "use sendfile" = false;
        "server multi channel support" = true;
        "deadtime" = 15;
        "min receivefile size" = 16384;
        "kernel change notify" = false;
        "store dos attributes" = true;
        "aio max threads" = 100;
        "aio read size" = 1;
        "aio write size" = 1;
        "hide special files" = true;
      };
      "Plain" = {
        "browseable" = "yes";
        "guest ok" = "no";
        "path" = "/Plain";
        "block size" = 4096;
        # shadow:snapdir = .zfs/snapshot
        # shadow:snapdirseverywhere = yes
        # shadow:sort = desc
        # shadow:format = -%Y-%m-%d-%H%M
        # shadow:snapprefix = ^zfs-auto-snap_\(frequent\)\{0,1\}\(hourly\)\{0,1\}\(daily\)\{0,1\}\(monthly\)\{0,1\}
        # shadow:delimiter = -20
        "read only" = "no";
        # "fruit:resource" = "xattr";
        # "fruit:copy" = "yes";
        # "fruit:locking" = "netatalk";
        # "fruit:veto_appledouble" = "no";
        # "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        # "fruit:delete_empty_adfiles" = "yes";
        "hide files" = "/.*/#*#/*~/$*/@*/desktop.ini/Thumbs.db/";
        "veto files" = "/*$RECYCLE.BIN/";
        "aio write behind" = "/*.tmp/*.log/";
        "kernel oplocks" = "yes";
      };
    };
  };

  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 111 2049 5357 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 3702 ];

  services.nfs.server = {
    enable = true;
  };
}
