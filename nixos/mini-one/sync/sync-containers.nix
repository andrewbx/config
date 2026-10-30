{ config, pkgs, ... }:

let
  work = config.myConfig.work;
  synologyToNixos = [
    "GetMail"
    "ProtonMail-Bridge"
  ];

  nixosToSynology = [
    "AirPrint"
    "Dockhand"
    "FreshRSS"
    "SearXNG"
    "UNS"
    "Vaultwarden"
    "LyrionMusicServer"
    "LibreNMS"
    "nTopNG"
    "Snort"
  ];

  syncContainers = {
    name,
    containers,
    sourceRoot,
    destinationRoot,
  }:

    let
      commands = builtins.concatStringsSep "\n" (
        map (container: ''
          echo "Syncing ${container}..."
          ${pkgs.rsync}/bin/rsync \
            -aHAX \
            --delete \
            "${sourceRoot}/${container}/" \
            "${destinationRoot}/${container}/"
        '') containers
      );
    in
    {
      description = "Docker container sync: ${name}";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "docker-sync-${name}" ''
          set -euo pipefail
          ${pkgs.util-linux}/bin/mountpoint -q ${work}/Shared/Docker
          echo "Starting Docker container sync: ${name}"
          ${commands}
          echo "Docker container sync completed: ${name}"
        '';
      };
    };
in
{
  systemd.services.docker-sync-synology-to-nixos =
    syncContainers {
      name = "synology-to-nixos";
      containers = synologyToNixos;
      sourceRoot = "${work}/Shared/Docker";
      destinationRoot = "${work}/Docker";
    };

  systemd.services.docker-sync-nixos-to-synology =
    syncContainers {
      name = "nixos-to-synology";
      containers = nixosToSynology;
      sourceRoot = "${work}/Docker";
      destinationRoot = "${work}/Shared/Docker";
    };

  systemd.timers.docker-sync-synology-to-nixos = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
    };
  };

  systemd.timers.docker-sync-nixos-to-synology = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
    };
  };
}
