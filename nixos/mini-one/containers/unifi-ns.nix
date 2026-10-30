{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  systemd.services.docker-unifi-ns-network = {
    description = "Create Unifi NS Docker network";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.docker}/bin/docker network inspect unifi-ns >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create unifi-ns
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.unifi-db = {
      image = "mongo:4.4";

      autoStart = true;

      environment = {
        MONGO_INITDB_ROOT_USERNAME = "root";
        MONGO_USER = "unifi";
        MONGO_DBNAME = "unifi";
        MONGO_AUTHSOURCE = "admin";
      };

      environmentFiles = [
        "/etc/docker/unifi-ns.env"
      ];

      volumes = [
        "${work}/Docker/UNS/db:/data/db"
        "${work}/Docker/UNS/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh:ro"
      ];

      extraOptions = [
        "--network=unifi-ns"
      ];
    };

    containers.unifi-network-application = {
      image = "linuxserver/unifi-network-application:latest";

      autoStart = true;

      dependsOn = [
        "unifi-db"
      ];

      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Europe/London";

        MONGO_USER = "unifi";
        MONGO_HOST = "unifi-db";
        MONGO_PORT = "27017";
        MONGO_DBNAME = "unifi";
        MONGO_AUTHSOURCE = "admin";

        MEM_LIMIT = "512";
        MEM_STARTUP = "256";
      };

      environmentFiles = [
        "/etc/docker/unifi-ns.env"
      ];

      volumes = [
        "${work}/Docker/UNS/data:/config"
      ];

      ports = [
        "8080:8080"       # Device inform port (required)
        "8444:8443"       # Web UI (HTTPS)
        "8843:8843"       # Guest portal HTTPS (optional)
        "8881:8880"       # Guest portal HTTP (optional)
        "6789:6789"       # Mobile throughput test (optional)
        "3478:3478/udp"   # STUN
        "10001:10001/udp" # AP discovery
        "1900:1900/udp"   # L2 discovery (optional)
        "5514:5514/udp"   # Remote syslog (optional)
      ];

      extraOptions = [
        "--network=unifi-ns"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    8080
    8444
    8843
    6789
  ];

  networking.firewall.allowedUDPPorts = [
    3478
    10001
    1900
    5514
  ];
}
