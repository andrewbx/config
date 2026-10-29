{ config, pkgs, lib, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
  zesaDir = "${work}/Retro/ZX";

  zesarux = pkgs.stdenv.mkDerivation {
    pname = "zesarux";
    version = "13.0";

    src = pkgs.fetchFromGitHub {
      owner = "chernandezba";
      repo = "zesarux";
      rev = "ZEsarUX-13.0";
      hash = "sha256-clwYn43Xswdo11T+aX78K1Qat5BoGwH3ByCT4qaMl8A=";
    };

    nativeBuildInputs = with pkgs; [
      pkg-config
      bash
    ];

    buildInputs = with pkgs; [
      libX11
      libXext
      libXxf86vm
      libpulseaudio
      alsa-lib
      libsndfile
      openssl
    ];

    configurePhase = ''
      cd src

      substituteInPlace configure \
        --replace-fail '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'

      ./configure --enable-ssl
    '';

    buildPhase = ''
      make -j$NIX_BUILD_CORES
    '';

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 zesarux $out/bin/zesarux
    '';

    meta = {
      description = "Sinclair ZX Emulator";
      homepage = "https://github.com/chernandezba/zesarux";
      license = lib.licenses.gpl3;
      platforms = lib.platforms.linux;
    };
  };
in
{
  environment.systemPackages = [
    zesarux
  ];

  systemd.tmpfiles.rules = [
    "d ${zesaDir} 0755 ${user} ${group} -"
    "d ${zesaDir}/Setup 0775 ${user} ${group} -"
    "d ${zesaDir}/Emulators 0775 ${user} ${group} -"
    "d ${zesaDir}/Library 0755 ${user} ${group} -"
    "d ${zesaDir}/Backup 0755 ${user} ${group} -"
    "d ${zesaDir}/Dev 0755 ${user} ${group} -"
  ];
}
