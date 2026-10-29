{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mame-tools
    kdePackages.k3b
    xorriso
    cdrdao
    cdrtools
    bchunk
    cdrkit
  ];
}
