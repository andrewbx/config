{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  systemd.services.docker-vaultwarden-network = {
    description = "Create Vaultwarden Docker network";
    after = [ "docker.service" ];
    wants = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.docker}/bin/docker network inspect vaultwarden >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create vaultwarden
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers.vaultwarden = {
      image = "vaultwarden/server:latest";

      cmd = [
        "/start.sh"
      ];

      hostname = "vaultwarden";

      environment = {
        PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
        ROCKET_PROFILE = "release";
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = "80";
        DEBIAN_FRONTEND = "noninteractive";
        EXPERIMENTAL_CLIENT_FEATURE_FLAGS =
          "extension-refresh,fido2-vault-credentials,ssh-key-vault-item,ssh-agent";
      };

      ports = [
        "880:80"
      ];

      volumes = [
        "${work}/Docker/Vaultwarden:/data:rw"
      ];

      autoStart = true;

      extraOptions = [
        "--network=vaultwarden"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    880
  ];
}
