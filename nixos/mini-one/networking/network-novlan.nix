{ config, pkgs, lib, ... }:

{
  # Enable networking.
  networking = {
    networkmanager.enable = false;
    wireless.enable = false;
    hostName = "mini-one";
    domain = "devnull.uk";
    dhcpcd.enable = false;
    dhcpcd.extraConfig = "nohook resolv.conf";
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 53 822 5380 853 443 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  # systemd network.
  systemd.network = {
    enable = true;
    networks = {
      "10-static-physical" = {
        matchConfig.Name = "enp4s0f0";
        networkConfig = {
          Address = [ "172.16.16.253/24" ];
          Gateway = "172.16.16.2";
          DNS = [ "172.16.16.2" ];
          DHCP = "no";
          IPv6AcceptRA = false;
        };

        linkConfig = {
          ActivationPolicy = "always-up";
        };
      };
    };
  };

  # systemd resolver.
  services.resolved.enable = false;

  environment.etc."resolv.conf".text = ''
    options edns0 rotate timeout:1 attempts:2
    nameserver 127.0.0.1
    nameserver 1.1.1.1
    nameserver 1.0.0.1
  '';
}
