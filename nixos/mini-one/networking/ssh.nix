{ ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 822 ];
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [
    822
  ];
}
