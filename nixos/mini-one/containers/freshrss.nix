{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  systemd.services.docker-freshrss-network = {
    description = "Create FreshRSS Docker network";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.docker}/bin/docker network inspect freshrss >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create freshrss
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      freshrss = {
        image = "lscr.io/linuxserver/freshrss:latest";

        ports = [
          "8882:80"
        ];

        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/London";
        };

        volumes = [
          "${work}/Docker/FreshRSS/config:/config"
        ];

        extraOptions = [
          "--network=freshrss"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8882
  ];
}
