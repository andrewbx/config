{ config, pkgs, lib, ... }:

{
  # Enable networking.
  networking = {
    networkmanager = {
      enable = true;
      settings = {
        device = {
          "wifi.scan-rand-mac-address" = "no";
        };
        connection = {
          "wifi.cloned-mac-address" = "permanent";
        };
      };
    };

    hostName = "dell-one";
    domain = "devnull.uk";
    resolvconf.enable = true;
  };

  # systemd resolver.
  services.resolved.enable = false;

  programs.winbox = {
    enable = true;
    openFirewall = true;
  };
}
