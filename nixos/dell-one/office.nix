{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-desktopeditors
  ];

  fonts = {
    packages = with pkgs; [
      corefonts
      liberation_ttf
      vista-fonts
      carlito
      caladea
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };
}
