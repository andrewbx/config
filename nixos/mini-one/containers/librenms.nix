{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  systemd.services.docker-librenms-network = {
    description = "Create LibreNMS Docker network";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.docker}/bin/docker network inspect librenms >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create librenms
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${work}/Docker/LibreNMS 0750 1000 1000 -"
    "d ${work}/Docker/LibreNMS/db 0750 999 999 -"
    "d ${work}/Docker/LibreNMS/data 0750 1000 1000 -"
  ];

  virtualisation.oci-containers.containers = {
    librenms-db = {
      image = "mariadb:10.11";
      autoStart = true;

      environmentFiles = [
        "/etc/docker/librenms.env"
      ];

      environment = {
        TZ = "Europe/London";
        MARIADB_RANDOM_ROOT_PASSWORD = "yes";
        MARIADB_DATABASE = "librenms";
        MARIADB_USER = "librenms";
      };

      volumes = [
        "${work}/Docker/LibreNMS/db:/var/lib/mysql"
      ];

      cmd = [
        "--innodb-file-per-table=1"
        "--lower-case-table-names=0"
      ];

      extraOptions = [
        "--network=librenms"
      ];
    };

    librenms-redis = {
      image = "redis:7-alpine";
      autoStart = true;

      environment = {
        TZ = "Europe/London";
      };

      extraOptions = [
        "--network=librenms"
      ];
    };

    librenms = {
      image = "librenms/librenms:latest";
      autoStart = true;

      ports = [
        "8000:8000"
      ];

      environmentFiles = [
        "/etc/docker/librenms.env"
      ];

      environment = {
        TZ = "Europe/London";

        DB_HOST = "librenms-db";
        DB_NAME = "librenms";
        DB_USER = "librenms";
        CACHE_STORE = "redis";
        REDIS_HOST = "librenms-redis";
      };

      volumes = [
        "${work}/Docker/LibreNMS/data:/data"
      ];

      extraOptions = [
        "--network=librenms"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];

      dependsOn = [
        "librenms-db"
        "librenms-redis"
      ];
    };

    librenms-syslog = {
      image = "librenms/librenms:latest";
      autoStart = true;

      ports = [
        "514:514/tcp"
        "514:514/udp"
      ];

      environmentFiles = [
        "/etc/docker/librenms.env"
      ];

      environment = {
        TZ = "Europe/London";

        DB_HOST = "librenms-db";
        DB_NAME = "librenms";
        DB_USER = "librenms";

        REDIS_HOST = "librenms-redis";
        SIDECAR_SYSLOGNG = "1";
      };

      volumes = [
        "${work}/Docker/LibreNMS/data:/data"
      ];

      extraOptions = [
        "--network=librenms"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];

      dependsOn = [
        "librenms-db"
        "librenms-redis"
      ];
    };

    librenms-dispatcher = {
      image = "librenms/librenms:latest";
      autoStart = true;

      environmentFiles = [
        "/etc/docker/librenms.env"
      ];

      environment = {
        TZ = "Europe/London";

        DB_HOST = "librenms-db";
        DB_NAME = "librenms";
        DB_USER = "librenms";

        REDIS_HOST = "librenms-redis";

        DISPATCHER_NODE_ID = "dispatcher1";
        SIDECAR_DISPATCHER = "1";
      };

      volumes = [
        "${work}/Docker/LibreNMS/data:/data"
      ];

      extraOptions = [
        "--network=librenms"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];

      dependsOn = [
        "librenms"
        "librenms-redis"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    514
    8000
  ];

  networking.firewall.allowedUDPPorts = [
    514
  ];
}
