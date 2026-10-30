{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /work/Docker/nTopNG 0750 root root - -"
    "d /work/Docker/nTopNG/redis 0750 101 102 - -"
  ];

  systemd.services.tzsp-replay = {
    description = "MikroTik TZSP to ntopng packet pipeline";

    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = [
      pkgs.bash
      pkgs.git
      pkgs.gnumake
      pkgs.stdenv.cc
      pkgs.coreutils
      pkgs.iproute2
      pkgs.libpcap
      pkgs.tcpreplay
    ];

    serviceConfig = {
      Type = "simple";
      StateDirectory = "tzsp-replay";
      Restart = "always";
      RestartSec = "3s";
    };

    preStart = ''
      set -euo pipefail

      src=/var/lib/tzsp-replay/src

      if [ ! -d "$src/.git" ]; then
        rm -rf "$src"
        git clone --depth 1 \
          https://github.com/thefloweringash/tzsp2pcap.git \
          "$src"
      else
        git -C "$src" pull --ff-only
      fi

      pcapDev="${pkgs.lib.getDev pkgs.libpcap}"
      pcapLib="${pkgs.lib.getLib pkgs.libpcap}"

      make -C "$src" clean all \
        CC="${pkgs.stdenv.cc}/bin/cc" \
        CFLAGS="-std=c99 -D_DEFAULT_SOURCE -Wall -Wextra -pedantic -O2 -I$pcapDev/include" \
        LDFLAGS="-L$pcapDev/lib -L$pcapLib/lib -Wl,-rpath,$pcapLib/lib"

      if ! ip link show tzsp0 >/dev/null 2>&1; then
        ip link add tzsp0 type dummy
      fi

      ip link set dev tzsp0 mtu 9216
      ip link set dev tzsp0 up
    '';

    script = ''
      set -euo pipefail

      exec ${pkgs.bash}/bin/bash -o pipefail -c '
        /var/lib/tzsp-replay/src/tzsp2pcap -p 37008 |
          ${pkgs.tcpreplay}/bin/tcpreplay-edit \
            --quiet \
            --suppress-warnings \
            --no-flow-stats \
            --topspeed \
            --mtu=9216 \
            --intf1=tzsp0 -
      '
    '';
  };

  virtualisation.oci-containers.containers.snort = {
    image = "local/snort3-core2";
    autoStart = true;

    extraOptions = [
      "--network=host"
      "--cap-add=NET_RAW"
      "--cap-add=NET_ADMIN"
      "--entrypoint=/usr/local/bin/snort"
    ];

    volumes = [
      "/work/Docker/Snort/etc:/etc/snort"
      "/work/Docker/Snort/logs:/var/log/snort"
    ];

    cmd = [
      "-i" "tzsp0"
      "-c" "/etc/snort/snort.lua"
      "-R" "/etc/snort/rules/all.rules"
      "-A" "alert_json"
      "--lua"
      "alert_json = { file = true, limit = 100, fields = 'timestamp seconds iface src_addr src_port dst_addr dst_port proto action msg priority class gid sid rev rule service' }"
      "--lua"
      "dofile('/etc/snort/suppress.lua')"
      "-l" "/var/log/snort"
    ];
  };

  systemd.services."docker-snort" = {
    requires = [ "tzsp-replay.service" ];
    after = [ "tzsp-replay.service" ];
  };

  virtualisation.oci-containers.containers.ntopng = {
    image = "ntop/ntopng:latest";
    autoStart = true;

    extraOptions = [
      "--network=host"
      "--cap-add=NET_RAW"
      "--cap-add=NET_ADMIN"
    ];

    volumes = [
      "/work/Docker/nTopNG:/var/lib/ntopng"
      "/work/Docker/nTopNG/redis:/var/lib/redis"
    ];

    cmd = [
      "-i" "tzsp0"
      "-w" "3002"
      "-n" "2"
    ];
  };

  systemd.services."docker-ntopng" = {
    requires = [ "tzsp-replay.service" ];
    after = [ "tzsp-replay.service" ];
  };

  networking.firewall.allowedUDPPorts = [
    37008
  ];

  networking.firewall.allowedTCPPorts = [
    3002
  ];
}
