{ pkgs, ... }:

{
  # Enable the SNMP Daemon.
  services.snmpd = {
    enable = true;

    configText = ''
      rocommunity dn_v2_snmp_co 172.16.16.253
      sysLocation "Home Network"
      sysContact "admin@devnull.uk"
    '';
  };

  networking.firewall.allowedUDPPorts = [
    161
  ];

  environment.systemPackages = with pkgs; [
    net-snmp
  ];
}
