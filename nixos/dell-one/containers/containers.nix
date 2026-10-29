{ config, pkgs, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
in
{
  imports =
    [
      # ./default.nix
    ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "userland-proxy" = false;
    };
  };

  systemd.tmpfiles.rules = [
     "d ${work}/Docker 0775 ${user} ${group} -"
  ];
}
