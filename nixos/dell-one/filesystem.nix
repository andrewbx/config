{ config, pkgs, ... }:

{
  # Actually load the drivers
  boot.kernelModules = [ "udf" "isofs" ];
  boot.initrd.availableKernelModules = [ "udf" "isofs" ];

  # Enable kernel support for NTFS, FAT32 and UDF, NFS
  boot.supportedFilesystems = [ "udf" "iso9660" "ntfs" "vfat" "nfs" ];

  # Enable disk automounting daemons
  security.polkit.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
          subject.isInGroup("wheel") &&
          subject.active &&
          subject.local) {
        return polkit.Result.YES;
      }
    });
  '';

  # Default NTFS mount options for user mounts
  environment.etc."udisks2/mount_options.conf".text = ''
    [defaults]
    ntfs_defaults=uid=$UID,gid=$GID,windows_names
    ntfs_allow=uid=$UID,gid=$GID,umask,dmask,fmask,windows_names,nls,exec
  '';

  boot.swraid = {
    enable = true;

    mdadmConf = ''
      MAILADDR root
    '';
  };

  environment.systemPackages = with pkgs; [
    mdadm
    ntfs3g
    exfatprogs
    file
    udftools
    nfs-utils
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
