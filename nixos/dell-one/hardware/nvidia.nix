{ config, pkgs, lib, ... }:

let
  nvidia580 = config.boot.kernelPackages.nvidiaPackages.legacy_580.overrideAttrs (old: {
    version = "580.178.04";

    src = pkgs.fetchurl {
      url = "https://download.nvidia.com/XFree86/Linux-x86_64/580.178.04/NVIDIA-Linux-x86_64-580.178.04.run";
      hash = "sha256-KcrGHoR+ZMdsFyI4myU8/eVls2f8GkNSX/j2JnZndyM=";
    };
  });
in
{
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    #package = nvidia580;

    open = false;

    modesetting.enable = true;
    nvidiaSettings = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };
}
