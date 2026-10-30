{ config, pkgs, lib, ... }:

let
  work = config.myConfig.work;
  srcdsUser = "srcds";
  srcdsGroup = "srcds";
  srcdsRoot = "${work}/Games/SRCDS";
  l4dRoot = "${srcdsRoot}/l4d";
  l4d2Root = "${srcdsRoot}/l4d2";
  l4dGameRoot = "${l4dRoot}/left4dead";
  l4d2GameRoot = "${l4d2Root}/left4dead2";

  sourcemodVersion = "1.11.0-git6970";
  metamodVersion = "1.11.0-git1156";

  sourcemodUrl =
    "https://www.sourcemod.net/smdrop/1.11/sourcemod-${sourcemodVersion}-linux.tar.gz";

  metamodUrl =
    "https://www.metamodsource.net/mmsdrop/1.11/mmsource-${metamodVersion}-linux.tar.gz";

  installScript = pkgs.writeShellScript "install-sourcemod" ''
    set -euo pipefail

    tmp=$(${pkgs.coreutils}/bin/mktemp -d)
    trap '${pkgs.coreutils}/bin/rm -rf "$tmp"' EXIT

    ${pkgs.curl}/bin/curl -fL \
      "${metamodUrl}" \
      -o "$tmp/metamod.tar.gz"

    ${pkgs.curl}/bin/curl -fL \
      "${sourcemodUrl}" \
      -o "$tmp/sourcemod.tar.gz"

    install_server() {
      local server_root="$1"
      local game_root="$2"
      local game_name="$3"

      echo "Installing SourceMod/Metamod for $game_name"

      ${pkgs.coreutils}/bin/mkdir -p "$server_root"

      ${pkgs.gnutar}/bin/tar \
        --use-compress-program=${pkgs.gzip}/bin/gzip \
        -xf "$tmp/metamod.tar.gz" \
        -C "$server_root"

      ${pkgs.gnutar}/bin/tar \
        --use-compress-program=${pkgs.gzip}/bin/gzip \
        -xf "$tmp/sourcemod.tar.gz" \
        -C "$server_root"

      # These are legacy 32-bit Source 1 servers.
      # Do not allow the x64 Metamod VDF to load.
      ${pkgs.coreutils}/bin/rm -f \
        "$game_root/addons/metamod_x64.vdf"

      echo "$game_name installation complete."
    }

    install_server \
      "${l4dRoot}" \
      "${l4dGameRoot}" \
      "Left 4 Dead"

    install_server \
      "${l4d2Root}" \
      "${l4d2GameRoot}" \
      "Left 4 Dead 2"

    # L4D1 requires its game-specific Metamod VDF.
    cat > "${l4dGameRoot}/addons/metamod.vdf" <<'EOF'
"Plugin"
{
	"file"	"../left4dead/addons/metamod/bin/server"
}
EOF

    echo "SourceMod/Metamod installation finished."
  '';

  l4dBuild = pkgs.writeShellScriptBin "l4d-build" ''
    set -euo pipefail

    if [ "$#" -ne 1 ]; then
      echo "Usage: l4d-build plugin.sp"
      exit 1
    fi

    source="$1"

    if [ ! -f "$source" ]; then
      echo "Source file not found: $source"
      exit 1
    fi

    compiler="${l4dGameRoot}/addons/sourcemod/scripting/spcomp"

    if [ ! -x "$compiler" ]; then
      echo "SourceMod compiler not found:"
      echo "$compiler"
      exit 1
    fi

    source_abs=$(${pkgs.coreutils}/bin/readlink -f "$source")
    source_dir=$(${pkgs.coreutils}/bin/dirname "$source_abs")
    source_file=$(${pkgs.coreutils}/bin/basename "$source_abs")
    plugin_name="''${source_file%.sp}"
    output="$source_dir/$plugin_name.smx"

    echo "Compiling $source_file..."

    ${pkgs.steam-run}/bin/steam-run "$compiler" \
      -i"${l4dGameRoot}/addons/sourcemod/scripting/include" \
      "$source_abs" \
      -o"$output"

    echo "Installing $plugin_name.smx..."

    ${pkgs.coreutils}/bin/install -m 0644 \
      "$output" \
      "${l4dGameRoot}/addons/sourcemod/plugins/$plugin_name.smx"

    if [ -d "$source_dir/gamedata" ]; then
      echo "Installing gamedata..."

      ${pkgs.coreutils}/bin/mkdir -p \
        "${l4dGameRoot}/addons/sourcemod/gamedata"

      ${pkgs.findutils}/bin/find "$source_dir/gamedata" \
        -maxdepth 1 \
        -type f \
        -exec ${pkgs.coreutils}/bin/install -m 0644 {} \
          "${l4dGameRoot}/addons/sourcemod/gamedata/" \;
    fi

    echo
    echo "Deployed:"
    echo "${l4dGameRoot}/addons/sourcemod/plugins/$plugin_name.smx"
  '';

  l4d2Build = pkgs.writeShellScriptBin "l4d2-build" ''
    set -euo pipefail

    if [ "$#" -ne 1 ]; then
      echo "Usage: l4d2-build plugin.sp"
      exit 1
    fi

    source="$1"

    if [ ! -f "$source" ]; then
      echo "Source file not found: $source"
      exit 1
    fi

    compiler="${l4d2GameRoot}/addons/sourcemod/scripting/spcomp"

    if [ ! -x "$compiler" ]; then
      echo "SourceMod compiler not found:"
      echo "$compiler"
      exit 1
    fi

    source_abs=$(${pkgs.coreutils}/bin/readlink -f "$source")
    source_dir=$(${pkgs.coreutils}/bin/dirname "$source_abs")
    source_file=$(${pkgs.coreutils}/bin/basename "$source_abs")
    plugin_name="''${source_file%.sp}"
    output="$source_dir/$plugin_name.smx"

    echo "Compiling $source_file..."

    ${pkgs.steam-run}/bin/steam-run "$compiler" \
      -i"${l4d2GameRoot}/addons/sourcemod/scripting/include" \
      "$source_abs" \
      -o"$output"

    echo "Installing $plugin_name.smx..."

    ${pkgs.coreutils}/bin/install -m 0644 \
      "$output" \
      "${l4d2GameRoot}/addons/sourcemod/plugins/$plugin_name.smx"

    if [ -d "$source_dir/gamedata" ]; then
      echo "Installing gamedata..."

      ${pkgs.coreutils}/bin/mkdir -p \
        "${l4d2GameRoot}/addons/sourcemod/gamedata"

      ${pkgs.findutils}/bin/find "$source_dir/gamedata" \
        -maxdepth 1 \
        -type f \
        -exec ${pkgs.coreutils}/bin/install -m 0644 {} \
          "${l4d2GameRoot}/addons/sourcemod/gamedata/" \;
    fi

    echo
    echo "Deployed:"
    echo "${l4d2GameRoot}/addons/sourcemod/plugins/$plugin_name.smx"
  '';

in
{
  environment.systemPackages = [
    l4dBuild
    l4d2Build
  ];

  systemd.tmpfiles.rules = [
    "d ${srcdsRoot}/plugins 0755 ${srcdsUser} ${srcdsGroup} -"
    "d ${srcdsRoot}/plugins/l4d 0755 ${srcdsUser} ${srcdsGroup} -"
    "d ${srcdsRoot}/plugins/l4d2 0755 ${srcdsUser} ${srcdsGroup} -"
  ];

  systemd.services.sourcemod-install = {
    description = "Install SourceMod and Metamod:Source";

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    serviceConfig = {
      Type = "oneshot";

      User = "srcds";
      Group = "srcds";

      ExecStart = installScript;
    };
  };
}
