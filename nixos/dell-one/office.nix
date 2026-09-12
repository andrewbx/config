{ config, pkgs, ... }:

let
  microsoft-fonts = pkgs.stdenvNoCC.mkDerivation {
    pname = "microsoft-office-fonts";
    version = "1.0";

    src = ./fonts;

    installPhase = ''
      install -Dm644 calibril.ttf \
        $out/share/fonts/truetype/calibril.ttf

      install -Dm644 calibrili.ttf \
        $out/share/fonts/truetype/calibrili.ttf

      install -Dm644 wingdings.ttf \
        $out/share/fonts/truetype/wingdings.ttf
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    onlyoffice-desktopeditors
    (pkgs.writeShellScriptBin "sync-onlyoffice-fonts" ''
      set -e

      dest="$HOME/.local/share/fonts/onlyoffice"

      mkdir -p "$dest"
      rm -f "$dest"/*

      cp -Lf /run/current-system/sw/share/X11/fonts/* "$dest/"

      fc-cache -f "$HOME/.local/share/fonts"
    '')
  ];

  fonts.packages = with pkgs; [
    corefonts
    liberation_ttf
    vista-fonts
    carlito
    caladea
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    dejavu_fonts
    symbola
    microsoft-fonts
    inter
    ibm-plex
    source-sans
    source-serif
    source-code-pro
    fira
  ];
}
