{ config, pkgs, lib, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
  viceDir = "${work}/Retro/C64";
in
{
  environment.systemPackages = with pkgs; [
    vice
  ];

  systemd.tmpfiles.rules = [
    "d ${viceDir} 0755 ${user} ${group} -"
    "d ${viceDir}/Setup 0775 ${user} ${group} -"
    "d ${viceDir}/Emulators 0775 ${user} ${group} -"
    "d ${viceDir}/Library 0755 ${user} ${group} -"
    "d ${viceDir}/Backup 0755 ${user} ${group} -"
    "d ${viceDir}/Dev 0755 ${user} ${group} -"
  ];
}
