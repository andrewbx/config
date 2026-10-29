{ config, pkgs, ... }:

let
  user = config.myConfig.user;
  group = config.myConfig.group;
  work = config.myConfig.work;
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      vhostUserPackages = with pkgs; [
        virtiofsd
        virglrenderer
      ];
    };
  };

  programs.virt-manager.enable = true;

  virtualisation.libvirtd.allowedBridges = [
    "virbr0"
  ];

  virtualisation.spiceUSBRedirection.enable = true;

  systemd.tmpfiles.rules = [
    "d ${work}/VM 0755 ${user} ${group} -"
  ];

  boot.kernelParams = [
    # "intel_iommu=on"
    # "iommu=pt"
  ];

  environment.systemPackages = with pkgs; [
    qemu_kvm
    virt-manager
    libguestfs
    OVMF
  ];
}
