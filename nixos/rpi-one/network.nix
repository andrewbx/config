{ config, pkgs, lib, ... }:

{
  # Enable networking.
  networking = {
    networkmanager.enable = false;
    wireless.enable = false;
    hostName = "rpi-one";
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
    resolvconf.enable = false;
  };

  # systemd network.
  systemd.network = {
    netdevs = {
      "10-vlan10" = {
        netdevConfig = {
          Name = "vlan10";
          Kind = "vlan";
        };
        vlanConfig.Id = 10;
      };
      "15-vlan15" = {
        netdevConfig = {
          Name = "vlan15";
          Kind = "vlan";
        };
        vlanConfig.Id = 15;
      };
      "16-vlan16" = {
        netdevConfig = {
          Name = "vlan16";
          Kind = "vlan";
        };
        vlanConfig.Id = 16;
      };
      "20-vlan20" = {
        netdevConfig = {
          Name = "vlan20";
          Kind = "vlan";
        };
        vlanConfig.Id = 20;
      };
      "25-vlan25" = {
        netdevConfig = {
          Name = "vlan25";
          Kind = "vlan";
        };
        vlanConfig.Id = 25;
      };
      "100-vlan100" = {
        netdevConfig = {
          Name = "vlan100";
          Kind = "vlan";
        };
        vlanConfig.Id = 100;
      };
    };
    networks = {
      "10-physical" = {
        matchConfig.Name = "enu1u1";
        vlan = [
          "vlan10"
          "vlan15"
          "vlan16"
          "vlan20"
          "vlan25"
          "vlan100"
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          LinkLocalAddressing = "no";
          DHCP = "no";
          IPv6AcceptRA = false;
        };
        linkConfig = {
          ActivationPolicy = "always-up";
          RequiredForOnline = "no";
        };
      };

      "10-vlan10" = {
        matchConfig.Name = "vlan10";
        networkConfig = {
          Address = [ "172.16.10.254/24" ];
          DNS = [ "172.16.10.254" ];
          IPv6AcceptRA = false;
        };
      };
      "15-vlan15" = {
        matchConfig.Name = "vlan15";
        networkConfig = {
          Address = [ "172.16.15.254/24" ];
          DNS = [ "172.16.15.254" ];
          IPv6AcceptRA = false;
        };
      };
      "16-vlan16" = {
        matchConfig.Name = "vlan16";
        networkConfig = {
          Address = [ "172.16.16.254/24" ];
          DNS = [ "172.16.16.254" ];
          Domains = [ "devnull.uk" ];
          Gateway = [ "172.16.16.2" ];
          IPv6AcceptRA = false;
        };
      };
      "20-vlan20" = {
        matchConfig.Name = "vlan20";
        networkConfig = {
          Address = [ "172.16.20.254/24" ];
          DNS = [ "172.16.20.254" ];
          IPv6AcceptRA = false;
        };
      };
      "25-vlan25" = {
        matchConfig.Name = "vlan25";
        networkConfig = {
          Address = [ "172.16.25.254/24" ];
          DNS = [ "172.16.25.254" ];
          IPv6AcceptRA = false;
        };
      };
      "100-vlan100" = {
        matchConfig.Name = "vlan100";
        networkConfig = {
          Address = [ "192.168.10.254/24" ];
          DNS = [ "192.168.10.254" ];
          IPv6AcceptRA = false;
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
