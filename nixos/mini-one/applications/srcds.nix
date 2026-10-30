{ config, pkgs, lib, ... }:

let
  work = config.myConfig.work;
  srcdsUser = "srcds";
  srcdsGroup = "srcds";
  srcdsRoot = "${work}/Games/SRCDS";
  l4dRoot = "${srcdsRoot}/l4d";
  l4d2Root = "${srcdsRoot}/l4d2";

  l4dStart = pkgs.writeShellScript "l4d-start" ''
    set -euo pipefail

    mode="$1"

    case "$mode" in
      coop)
        gamemode="coop"
        map="l4d_hospital01_apartment"
        maxplayers="4"
        ;;
      vs)
        gamemode="versus"
        map="l4d_hospital01_apartment"
        maxplayers="8"
        ;;
      *)
        echo "Unknown L4D mode: $mode"
        echo "Valid modes: coop, vs"
        exit 1
        ;;
    esac

    exec ${pkgs.steam-run}/bin/steam-run \
      ${l4dRoot}/srcds_run \
      -console \
      -game left4dead \
      -port 27015 \
      +maxplayers "$maxplayers" \
      +mp_gamemode "$gamemode" \
      +map "$map"
  '';

  l4d2Start = pkgs.writeShellScript "l4d2-start" ''
    set -euo pipefail

    mode="$1"

    case "$mode" in
      coop)
        gamemode="coop"
        map="c1m1_hotel"
        maxplayers="8"
        ;;
      vs)
        gamemode="versus"
        map="c1m1_hotel"
        maxplayers="8"
        ;;
      *)
        echo "Unknown L4D2 mode: $mode"
        echo "Valid modes: coop, vs"
        exit 1
        ;;
    esac

    exec ${pkgs.steam-run}/bin/steam-run \
      ${l4d2Root}/srcds_run \
      -console \
      -game left4dead2 \
      -port 27015 \
      +maxplayers "$maxplayers" \
      +mp_gamemode "$gamemode" \
      +map "$map"
  '';

  l4dClean = pkgs.writeShellScriptBin "l4d-clean" ''
    set -euo pipefail

    echo "Cleaning Left 4 Dead dedicated server..."

    ${pkgs.systemd}/bin/systemctl stop 'l4d@*' 2>/dev/null || true

    addons="${l4dRoot}/left4dead/addons"
    backup="$(${pkgs.coreutils}/bin/mktemp -d)/addons"

    if [ ! -d "$addons" ]; then
      echo "ERROR: $addons does not exist."
      echo "Refusing to uninstall L4D."
      exit 1
    fi

    echo "Preserving $addons..."
    ${pkgs.coreutils}/bin/mv "$addons" "$backup"

    trap '${pkgs.coreutils}/bin/mkdir -p "${l4dRoot}/left4dead"; ${pkgs.coreutils}/bin/mv "$backup" "$addons" 2>/dev/null || true' EXIT

    ${pkgs.steamcmd}/bin/steamcmd \
      +force_install_dir "${l4dRoot}" \
      +login anonymous \
      +app_uninstall 222840 \
      +quit

    ${pkgs.coreutils}/bin/mkdir -p "${l4dRoot}/left4dead"
    ${pkgs.coreutils}/bin/mv "$backup" "$addons"

    trap - EXIT

    echo "L4D cleanup complete."
  '';

  l4d2Clean = pkgs.writeShellScriptBin "l4d2-clean" ''
    set -euo pipefail

    echo "Cleaning Left 4 Dead 2 dedicated server..."

    ${pkgs.systemd}/bin/systemctl stop 'l4d2@*' 2>/dev/null || true

    addons="${l4d2Root}/left4dead2/addons"
    backup="$(${pkgs.coreutils}/bin/mktemp -d)/addons"

    if [ ! -d "$addons" ]; then
      echo "ERROR: $addons does not exist."
      echo "Refusing to uninstall L4D2."
      exit 1
    fi

    echo "Preserving $addons..."
    ${pkgs.coreutils}/bin/mv "$addons" "$backup"

    trap '${pkgs.coreutils}/bin/mkdir -p "${l4d2Root}/left4dead2"; ${pkgs.coreutils}/bin/mv "$backup" "$addons" 2>/dev/null || true' EXIT

    ${pkgs.steamcmd}/bin/steamcmd \
      +force_install_dir "${l4d2Root}" \
      +login anonymous \
      +app_uninstall 222860 \
      +quit

    ${pkgs.coreutils}/bin/mkdir -p "${l4d2Root}/left4dead2"
    ${pkgs.coreutils}/bin/mv "$backup" "$addons"

    trap - EXIT

    echo "L4D2 cleanup complete."
  '';
in
{
  networking.firewall.allowedUDPPorts = [
    27015
    27020
  ];

  users.groups.${srcdsUser} = {};

  users.users.${srcdsUser} = {
    isSystemUser = true;
    group = "${srcdsGroup}";
    home = srcdsRoot;
    createHome = false;
  };

  environment.systemPackages = [
    pkgs.steamcmd
    pkgs.steam-run
    l4dClean
    l4d2Clean
  ];

  systemd.tmpfiles.rules = [
    "d ${srcdsRoot} 0755 ${srcdsUser} ${srcdsGroup} -"
    "d ${l4dRoot} 0755 ${srcdsUser} ${srcdsGroup} -"
    "d ${l4d2Root} 0755 ${srcdsUser} ${srcdsGroup} -"
    "d ${srcdsRoot}/.steam/sdk32 0755 ${srcdsUser} ${srcdsGroup} -"
    "L+ ${srcdsRoot}/.steam/sdk32/steamclient.so - - - - ${srcdsRoot}/steamcmd/linux32/steamclient.so"
  ];

  systemd.services.l4d-update = {
    description = "Update Left 4 Dead Dedicated Server";

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    serviceConfig = {
      Type = "oneshot";

      User = "root";
      Group = "root";

      WorkingDirectory = l4dRoot;

      ExecStart = pkgs.writeShellScript "l4d-update" ''
        set -euo pipefail

        echo "Updating Left 4 Dead dedicated server..."

        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir "${l4dRoot}" \
          +login anonymous \
          +@sSteamCmdForcePlatformType windows \
          +app_update 222840 \
          +@sSteamCmdForcePlatformType linux \
          +app_update 222840 validate \
          +quit

        echo "L4D update complete."
      '';
    };
  };

  systemd.services."l4d@" = {
    description = "Left 4 Dead Dedicated Server (%i)";

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "srcds";
      Group = "srcds";
      WorkingDirectory = l4dRoot;
      ExecStart = "${l4dStart} %i";
      Restart = "on-failure";
      RestartSec = 5;
      LimitNOFILE = 65535;
    };
  };

  systemd.services.l4d2-update = {
    description = "Update Left 4 Dead 2 Dedicated Server";

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    serviceConfig = {
      Type = "oneshot";

      User = "root";
      Group = "root";

      WorkingDirectory = l4d2Root;

      ExecStart = pkgs.writeShellScript "l4d2-update" ''
        set -euo pipefail

        echo "Updating Left 4 Dead 2 dedicated server..."

        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir "${l4d2Root}" \
          +login anonymous \
          +@sSteamCmdForcePlatformType windows \
          +app_update 222860 \
          +@sSteamCmdForcePlatformType linux \
          +app_update 222860 validate \
          +quit

        echo "L4D2 update complete."
      '';
    };
  };

  systemd.services."l4d2@" = {
    description = "Left 4 Dead 2 Dedicated Server (%i)";

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = "srcds";
      Group = "srcds";

      WorkingDirectory = l4d2Root;

      ExecStart = "${l4d2Start} %i";

      Restart = "on-failure";
      RestartSec = 5;
      LimitNOFILE = 65535;
    };
  };
}
