{ config, lib, pkgs, ... }:

let
  romvault = pkgs.stdenv.mkDerivation rec {
    pname = "romvault";
    version = "3.8.0";

    src = pkgs.fetchurl {
      url = "https://www.romvault.com/download/ROMVault_V3.8.0.zip";
      hash = "sha256-BIJG0Jzf1+ipWUrxx6/mx/6PyQAl7a3n0D95Z9CgNcc=";
    };

    nativeBuildInputs = [
      pkgs.unzip
    ];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/romvault
      ${pkgs.unzip}/bin/unzip -q $src -d $out/share/romvault
    '';
  };

  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
  rvDir = "${work}/Retro/RomVault";
in
{
  environment.systemPackages = [
    pkgs.mono
  ];

  systemd.tmpfiles.rules = [
    "d ${rvDir} 0755 ${user} ${group} -"
    "d ${rvDir}/DatRoot 0755 ${user} ${group} -"
    "d ${rvDir}/RomRoot 0755 ${user} ${group} -"
    "d ${rvDir}/ToSort 0755 ${user} ${group} -"
  ];

  systemd.services.romvault-install = {
    description = "Install RomVault into ${work}/RomVault";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      mkdir -p ${rvDir}

      if [ ! -f ${rvDir}/ROMVault3.exe ]; then
        cp -r ${romvault}/share/romvault/* ${rvDir}/
        chown -R ${user}:${group} ${rvDir}
      fi
    '';
  };

  environment.etc."xdg/applications/romvault.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=RomVault
    Comment=ROM collection manager
    Exec=${pkgs.mono}/bin/mono ${rvDir}/ROMVault3.exe
    Path=${rvDir}
    Terminal=false
    Categories=Utility;
  '';
}
