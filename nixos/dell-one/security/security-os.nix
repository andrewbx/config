{...}: {
  boot.kernel.sysctl = {
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = false;
    "kernel.kptr_restrict" = 2;
    "kernel.sysrq" = false;
    "kernel.unprivileged_bpf_disabled" = true;
    "kernel.yama.ptrace_scope" = 2;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.accept_redirects" = false;
    "net.ipv4.conf.default.accept_redirects" = false;
    "net.ipv6.conf.all.accept_redirects" = false;
    "net.ipv6.conf.default.accept_redirects" = false;
    "net.ipv4.conf.all.accept_source_route" = false;
    "net.ipv4.conf.default.accept_source_route" = false;
    "net.ipv6.conf.all.accept_source_route" = false;
    "net.ipv6.conf.default.accept_source_route" = false;
    "net.ipv4.conf.all.log_martians" = false;
    "net.ipv4.conf.default.log_martians" = false;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.send_redirects" = false;
    "net.ipv4.icmp_echo_ignore_broadcasts" = true;
    "net.ipv4.icmp_ignore_bogus_error_responses" = true;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.default.autoconf" = 0;
    "net.ipv6.bindv6only" = 0;
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv4.tcp_rfc1337" = true;
    "net.ipv4.tcp_fastopen" = 3;
  };

  # fileSystems."/proc" = {
  #   device = "proc";
  #   fsType = "proc";
  #   options = ["defaults" "hidepid=2"];
  #   neededForBoot = true;
  # };

  boot.blacklistedKernelModules = [
    # Amateur radio protocols
    "ax25"
    "netrom"
    "rose"

    # Legacy/Uncommon protocols
    "decnet"
    "econet"
    "af_802154"
    "can"
    "appletalk"
    "psnap"
    "p8023"
    "p8022"
    "snap"
    "dccp"
    "sctp"
    "rds"
    "tipc"

    # Uncommon filesystems
    "cramfs"
    "freevxfs"
    "jffs2"
  ];

  services.dbus.implementation = "broker";
  security.sudo.execWheelOnly = true;

  systemd.services.systemd-rfkill = {
    serviceConfig = {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/systemd/rfkill" ];
      ProtectKernelTunables = false; 
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      PrivateTmp = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      LockPersonality = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
      IPAddressDeny = "any";
    };
  };

  systemd.services.systemd-journald = {
    serviceConfig = {
      UMask = 0077;
      PrivateNetwork = true;
      ProtectHostname = true;
      ProtectKernelModules = true;
    };
  };

  # Enable ClamAV.
  services.clamav.daemon.enable = false;
  services.clamav.updater.enable = false;
  services.clamav.daemon.settings = {
    ScanArchive = "no";
    MaxFileSize = "20M";
    MaxScanSize = "50M";
    MaxThreads = "2";
  };

  systemd.services.clamav-daemon.serviceConfig = {
    MemoryMax = "1G";
    MemorySwapMax = "500M";
  };

  # Enable firejail.
  programs.firejail.enable = false;

  # Coredump.
  systemd.coredump.enable = true;
}
