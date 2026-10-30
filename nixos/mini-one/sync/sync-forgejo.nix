{ config, pkgs, ... }:

let
  work = config.myConfig.work;
  mountpoint = "${work}/Shared/Productivity";
  syncfrom = "${work}/Forgejo/repositories";
  syncto = "${mountpoint}/Dev/Git";

  nixosToSynology = [
    "andrewbx"
    "public"
    "home"
    "forks"
  ];

  syncRepositories = {
    name,
    repositories,
    sourceRoot,
    destinationRoot,
  }:

    let
      commands = builtins.concatStringsSep "\n" (
        map (repository: ''
          echo "Syncing ${repository}..."
          ${pkgs.rsync}/bin/rsync \
            -aHAX \
            --delete \
            "${sourceRoot}/${repository}/" \
            "${destinationRoot}/${repository}/"
        '') repositories
      );
    in
    {
      description = "Git repositories sync: ${name}";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "git-sync-${name}" ''
          set -euo pipefail
          ${pkgs.util-linux}/bin/mountpoint -q ${mountpoint}
          echo "Starting Git repositories sync: ${name}"
          ${commands}
          echo "Git repositories sync completed: ${name}"
        '';
      };
    };
in
{
  systemd.services.git-sync-nixos-to-synology =
    syncRepositories {
      name = "nixos-to-synology";
      repositories = nixosToSynology;
      sourceRoot = "${syncfrom}";
      destinationRoot = "${syncto}";
    };

  systemd.timers.git-sync-nixos-to-synology = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "01:00";
      Persistent = true;
    };
  };
}
