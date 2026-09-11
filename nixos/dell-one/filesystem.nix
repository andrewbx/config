{ config, pkgs, ... }:

{
  boot.swraid = {
    enable = true;

    mdadmConf = ''
      MAILADDR root
    '';
  };

  environment.systemPackages = with pkgs; [
    mdadm
  ];

  fileSystems."/work" =
    { device = "/dev/disk/by-uuid/b3b39d14-a3a7-4b7d-8fec-2c4709bee98e";
      fsType = "ext4";
    };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/520b4555-0454-4cc3-9d38-94726805fb93";
    fsType = "ext4";
  };
}
