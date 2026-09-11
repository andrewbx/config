{ config, pkgs, ... }:

{
 # Filesystem options.
  fileSystems."/" = {
    options = [ 
      "noatime"
    ];
  };

  # Activate swapfile.
  # swapDevices = [
  #   { 
  #     device = "/swapfile";
  #     size = 2048;
  #   }
  # ];
}
