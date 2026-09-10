{ config, pkgs, ... }:

{
  boot.kernelModules = [
    "kvm-intel"
  ];

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
    "d /work/VM 0775 root users -"
  ];

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "mitigations=off"
  ];

  boot.kernel.sysctl."vm.nr_hugepages" = 4096;

  environment.systemPackages = with pkgs; [
    qemu_kvm
    virt-manager
    libguestfs
    OVMF
  ];
}
