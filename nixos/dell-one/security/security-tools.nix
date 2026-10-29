{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nmap
    lynis
    aircrack-ng
    tcpdump
    tshark
  ];
}
