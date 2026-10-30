{ config, pkgs, ... }:

let
  work = config.myConfig.work;
in
{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.lyrionmusicserver = {
      image = "lmscommunity/lyrionmusicserver:latest";

      environment = {
        TZ = "Europe/London";
      };

      ports = [
        "9000:9000"
      ];

      volumes = [
        "${work}/Docker/LyrionMusicServer/config:/config:rw"
        "${work}/Docker/LyrionMusicServer/music:/music:ro"
        "${work}/Docker/LyrionMusicServer/playlist:/playlist:rw"
      ];

      extraOptions = [
        "--network=host"
      ];

      autoStart = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    3483
    9000
  ];
}
