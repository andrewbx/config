{ config, pkgs, lib, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
  mameDir = "${work}/Retro/MAME";
in
{
  environment.systemPackages = [
    pkgs.mame
  ];

  systemd.tmpfiles.rules = [
    "d ${mameDir} 0755 ${user} ${group} -"
    "d ${mameDir}/Setup 0775 ${user} ${group} -"
    "d ${mameDir}/Emulators 0775 ${user} ${group} -"
    "d ${mameDir}/Library 0755 ${user} ${group} -"
    "d ${mameDir}/Backup 0755 ${user} ${group} -"
    "d ${mameDir}/Dev 0755 ${user} ${group} -"
  ];
}
