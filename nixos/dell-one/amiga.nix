{ config, pkgs, lib, ... }:

let
  user = "andrew";
  group = "users";
  home = "/home/${user}";

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
    lhasa
    uade
    libao
    amitools
  ];

  # Enable kernel support for FFS
  boot.supportedFilesystems = [ "affs" ];

  systemd.tmpfiles.rules = [
    "d /work/Amiga 0755 ${user} ${group} -"
    "d /work/Amiga/Setup 0775 ${user} ${group} -"
    "d /work/Amiga/Emulators 0775 ${user} ${group} -"
    "d /work/Amiga/Emulators/FS-UAE 0775 ${user} ${group} -"
    "d /work/Amiga/Modules 0775 ${user} ${group} -"
    "d /work/Amiga/Library 0775 ${user} ${group} -"
    "d /work/Amiga/Backup 0775 ${user} ${group} -"
    "d /work/Amiga/Dev 0775 ${user} ${group} -"

    # FS-UAE default directory -> Amiga FS-UAE directory
    "L+ ${home}/Documents/FS-UAE - - - - /work/Amiga/Emulators/FS-UAE"
  ];
}
