{ config, pkgs, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
in
{
  imports =
    [
      ./dockhand.nix
      ./searxng.nix
      ./freshrss.nix
      ./airprint.nix
      ./vaultwarden.nix
      ./unifi-ns.nix
      ./lms.nix
      ./librenms.nix
      ./ntopng.nix
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
