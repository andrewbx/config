{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      dockhand = {
        image = "fnsys/dockhand:d8a41063-baseline";

        ports = [
          "3000:3000"
        ];

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${work}/Docker/Dockhand:/app/data"
        ];

        extraOptions = [
          "--group-add=131"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    3000
  ];
}
