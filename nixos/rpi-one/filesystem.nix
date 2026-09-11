{ config, pkgs, ... }:

{
 # Filesystem options.
  fileSystems."/" = {
    options = [ 
      "noatime"
      "commit=60"
    ];
  };

  # Activate swapfile.
  swapDevices = [
    { 
      device = "/swapfile";
      size = 2048;
    }
  ];
}
