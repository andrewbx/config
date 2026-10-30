{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  systemd.services.docker-searxng-network = {
    description = "Create SearXNG Docker network";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.docker}/bin/docker network inspect searxng >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create searxng
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      searxng = {
        image = "searxng/searxng:latest";

        ports = [
          "7780:8080"
        ];

        user = "1000:100";  

        environment = {
          TZ = "Europe/London";
        };

        volumes = [
          "${work}/Docker/SearXNG:/etc/searxng:rw"
        ];

        dependsOn = [
          "valkey"
        ];

        extraOptions = [
          "--hostname=searxng"
          "--network=searxng"
        ];
      };

      valkey = {
        image = "docker.io/valkey/valkey:8-alpine";

        cmd = [
          "valkey-server"
          "--save"
          ""
          "--appendonly"
          "no"
        ];

        extraOptions = [
          "--network=searxng"
          "--cap-drop=ALL"
          "--cap-add=SETGID"
          "--cap-add=SETUID"
          "--cap-add=DAC_OVERRIDE"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    7780
  ];
}
