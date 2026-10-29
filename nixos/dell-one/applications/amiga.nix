{ config, pkgs, lib, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  home = "/home/${user}";
  work = config.myConfig.work;
  amigaDir = "${work}/Retro/Amiga";

  audacious-gtk3 = pkgs.symlinkJoin {
    name = "audacious-gtk3";
    paths = [ pkgs.audacious ];

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/audacious \
        --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';
  };

  amitools = pkgs.python3Packages.buildPythonPackage rec {
    pname = "amitools";
    version = "0.8.1";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-9iLAclwVc359SCDtFH+TD0z7e4CwTHhsK8OUO3mfr34=";
    };

    pyproject = true;

    build-system = with pkgs.python3Packages; [
      setuptools
      setuptools-scm
      cython
    ];

    doCheck = false;
  };

  lhafile = pkgs.python3Packages.buildPythonPackage rec {
    pname = "lhafile";
    version = "0.3.1";

    pyproject = true;

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-pmoJHmGvVpOEhE7XS/dhecV15dKLyIv5v1R2ozl9B30=";
    };

    build-system = with pkgs.python3Packages; [
      setuptools
    ];

    pythonImportsCheck = [
      "lhafile"
    ];
  };

  fsuaeLauncher = pkgs.fsuae-launcher.overrideAttrs (old: rec {
    version = "3.2.35";

    src = pkgs.fetchFromGitHub {
      owner = "FrodeSolheim";
      repo = "fs-uae-launcher";
      rev = "c132e6e";
      hash = "sha256-ggzius1jVtjWerzBpY5oLcPqymN9IVDCwQz+bW9igGg=";
    };

    buildInputs =
      (old.buildInputs or [])
      ++ [
        lhafile
        pkgs.python3Packages.pyopengl
        pkgs.python3Packages.distutils
        pkgs.python3Packages.setuptools
        pkgs.libsForQt5.qtwayland
      ];
      qtWrapperArgs = (old.qtWrapperArgs or []) ++ [
        "--set QT_QPA_PLATFORM wayland"
        "--prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.qtwayland.bin}/lib/qt-5.15.19/plugins"
      ];
  });
in
{
  environment.systemPackages = with pkgs; [
    fsuae
    fsuaeLauncher
    lhafile
    lhasa
    uade
    libao
    amitools
    audacious-gtk3
  ];

  # Enable kernel support for FFS
  boot.supportedFilesystems = [ "affs" ];

  systemd.tmpfiles.rules = [
    "d ${amigaDir} 0755 ${user} ${group} -"
    "d ${amigaDir}/Setup 0775 ${user} ${group} -"
    "d ${amigaDir}/Emulators 0775 ${user} ${group} -"
    "d ${amigaDir}/Emulators/FS-UAE 0755 ${user} ${group} -"
    "d ${amigaDir}/Modules 0755 ${user} ${group} -"
    "d ${amigaDir}/Library 0755 ${user} ${group} -"
    "d ${amigaDir}/Backup 0755 ${user} ${group} -"
    "d ${amigaDir}/Dev 0755 ${user} ${group} -"

    # FS-UAE default directory -> Amiga FS-UAE directory
    "L+ ${home}/Documents/FS-UAE - - - - ${amigaDir}/Emulators/FS-UAE"
  ];
}
