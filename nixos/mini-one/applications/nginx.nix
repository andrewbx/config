{ config, pkgs, lib, ... }:
{
  services.nginx = {
    enable = true;

    virtualHosts."pxe.local" = {
      root = "/srv/http";
      locations."/" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/http 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];
}
