{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.airprint = {
      image = "chuckcharlie/cups-avahi-airprint:latest";

      autoStart = true;

      environmentFiles = [
        "/etc/docker/airprint.env"
      ];

      environment = {
        DEBIAN_FRONTEND = "noninteractive";
        TZ = "BST";
      };

      extraOptions = [
        "--network=host"
        "--device=/dev/bus/usb:/dev/bus/usb"
      ];

      volumes = [
        "${work}/Docker/AirPrint/services:/services"
        "${work}/Docker/AirPrint/config:/config"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    631
  ];

  networking.firewall.allowedUDPPorts = [
    5353
  ];
}
