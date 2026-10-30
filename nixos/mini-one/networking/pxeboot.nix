{ config, pkgs, lib, ... }:

let
  tftpRoot = "/srv/tftp";
  httpRoot = "/srv/http";
  
  pxebootUrl = "http://pxeboot.devnull.uk";
  ipxeUrl = "https://boot.ipxe.org";

  debianI386Url =
    "https://deb.debian.org/debian/dists/bookworm/main/installer-i386/current/images/netboot/debian-installer/i386";

  debianAmd64Url =
    "https://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64";

  slackware32Url =
    "https://mirrors.slackware.com/slackware/slackware-15.0";

  slackware64Url =
    "https://mirrors.slackware.com/slackware/slackware64-15.0";

  rocky10Url =
    "https://download.rockylinux.org/pub/rocky/10.2/BaseOS/x86_64/os";

  almaUrl =
    "https://repo.almalinux.org/almalinux/10/BaseOS/x86_64/os";

  almaV2Url =
    "https://repo.almalinux.org/almalinux/10/BaseOS/x86_64_v2/os";

  alpineUrl =
    "https://dl-cdn.alpinelinux.org/alpine/latest-stable";

in
{
  services.tftpd = {
    enable = true;
    path = tftpRoot;
  };

  systemd.tmpfiles.rules = [
    "d ${tftpRoot} 0755 root root -"
    "d ${tftpRoot}/pxelinux.cfg 0755 root root -"

    "d ${tftpRoot}/ipxe 0755 root root -"

    "d ${tftpRoot}/nixos 0755 root root -"
    "d ${httpRoot}/nixos 0755 root root -"

    "d ${tftpRoot}/debian 0755 root root -"
    "d ${tftpRoot}/debian/bookworm-i386 0755 root root -"
    "d ${tftpRoot}/debian/stable-amd64 0755 root root -"
    "d ${httpRoot}/debian 0755 root root -"
    "d ${httpRoot}/debian/bookworm-i386 0755 root root -"
    "d ${httpRoot}/debian/stable-amd64 0755 root root -"

    "d ${tftpRoot}/slackware 0755 root root -"
    "d ${tftpRoot}/slackware/32bit 0755 root root -"
    "d ${tftpRoot}/slackware/64bit 0755 root root -"
    "d ${httpRoot}/slackware 0755 root root -"
    "d ${httpRoot}/slackware/32bit 0755 root root -"
    "d ${httpRoot}/slackware/64bit 0755 root root -"

    "d ${tftpRoot}/rocky 0755 root root -"
    "d ${tftpRoot}/rocky/10 0755 root root -"
    "d ${httpRoot}/rocky 0755 root root -"
    "d ${httpRoot}/rocky/10 0755 root root -"

    "d ${tftpRoot}/alma 0755 root root -"
    "d ${tftpRoot}/alma/10 0755 root root -"
    "d ${tftpRoot}/alma/10/v2 0755 root root -"
    "d ${httpRoot}/alma 0755 root root -"
    "d ${httpRoot}/alma/10 0755 root root -"
    "d ${httpRoot}/alma/10/v2 0755 root root -"

    "d ${tftpRoot}/alpine 0755 root root -"
    "d ${httpRoot}/alpine 0755 root root -"
  ];

  systemd.services.pxeboot-update = {
    description = "Build and install PXE boot files";

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      set -euo pipefail

      mkdir -p ${tftpRoot}/pxelinux.cfg
      mkdir -p ${tftpRoot}/nixos
      mkdir -p ${tftpRoot}/debian/bookworm-i386
      mkdir -p ${tftpRoot}/debian/stable-amd64
      mkdir -p ${tftpRoot}/slackware/32bit
      mkdir -p ${tftpRoot}/slackware/64bit
      mkdir -p ${tftpRoot}/rocky/10
      mkdir -p ${tftpRoot}/alma/10
      mkdir -p ${tftpRoot}/memtest

      mkdir -p ${httpRoot}/nixos
      mkdir -p ${httpRoot}/debian/bookworm-i386
      mkdir -p ${httpRoot}/debian/stable-amd64
      mkdir -p ${httpRoot}/slackware/32bit
      mkdir -p ${httpRoot}/slackware/64bit
      mkdir -p ${httpRoot}/rocky/10
      mkdir -p ${httpRoot}/alma/10
      mkdir -p ${httpRoot}/memtest

      echo "============================================"
      echo " Building reduced NixOS netboot image 26.05 "
      echo "============================================"

      netboot="$(
        ${pkgs.nix}/bin/nix-build \
          -I nixpkgs=${pkgs.path} \
          --expr '
            let
              nixpkgs = import <nixpkgs> {};

              evaluated = import <nixpkgs/nixos/lib/eval-config.nix> {
                system = "x86_64-linux";

                modules = [
                  <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>

                  {
                    system.installer.channel.enable = false;
                  }
                ];
              };

              nixos = evaluated.config;
            in
              nixpkgs.linkFarm "nixos-netboot" [
                {
                  name = "bzImage";
                  path = "''${nixos.system.build.kernel}/bzImage";
                }

                {
                  name = "initrd";
                  path = "''${nixos.system.build.netbootRamdisk}/initrd";
                }

                {
                  name = "netboot.ipxe";
                  path = nixos.system.build.netbootIpxeScript;
                }
              ]
          ' \
          --no-out-link
      )"

      echo "NixOS netboot result: $netboot"

      echo
      echo "========================================"
      echo " Installing PXELINUX"
      echo "========================================"

      install -m 0644 \
        ${pkgs.syslinux}/share/syslinux/pxelinux.0 \
        ${tftpRoot}/pxelinux.0

      install -m 0644 \
        ${pkgs.syslinux}/share/syslinux/ldlinux.c32 \
        ${tftpRoot}/ldlinux.c32

      install -m 0644 \
        ${pkgs.syslinux}/share/syslinux/menu.c32 \
        ${tftpRoot}/menu.c32

      install -m 0644 \
        ${pkgs.syslinux}/share/syslinux/libcom32.c32 \
        ${tftpRoot}/libcom32.c32

      install -m 0644 \
        ${pkgs.syslinux}/share/syslinux/libutil.c32 \
        ${tftpRoot}/libutil.c32

      echo
      echo "========================================"
      echo " Installing iPXE"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/ipxe/undionly.kpxe \
        ${ipxeUrl}/i386-pcbios/undionly.kpxe

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/ipxe/ipxe.efi \
        ${ipxeUrl}/x86_64-efi/ipxe.efi

      ${pkgs.curl}/bin/curl -fL --retry 3 \
         --output ${tftpRoot}/ipxe/ipxe-arm64.efi \
        ${ipxeUrl}/arm64-efi/ipxe.efi

      echo
      echo "========================================"
      echo " Installing NixOS 26.05"
      echo "========================================"

      install -m 0644 \
        "$netboot/bzImage" \
        ${tftpRoot}/nixos/bzImage

      install -m 0644 \
        "$netboot/initrd" \
        ${tftpRoot}/nixos/initrd

      cp ${tftpRoot}/nixos/bzImage ${httpRoot}/nixos/bzImage
      cp ${tftpRoot}/nixos/initrd ${httpRoot}/nixos/initrd

      echo
      echo "========================================"
      echo " Downloading Debian 12 i386"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/debian/bookworm-i386/linux \
        ${debianI386Url}/linux

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/debian/bookworm-i386/initrd.gz \
        ${debianI386Url}/initrd.gz

      cp ${tftpRoot}/debian/bookworm-i386/linux ${httpRoot}/debian/bookworm-i386/linux
      cp ${tftpRoot}/debian/bookworm-i386/initrd.gz ${httpRoot}/debian/bookworm-i386/initrd.gz

      echo
      echo "========================================"
      echo " Downloading Debian stable amd64"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/debian/stable-amd64/linux \
        ${debianAmd64Url}/linux

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/debian/stable-amd64/initrd.gz \
        ${debianAmd64Url}/initrd.gz

      cp ${tftpRoot}/debian/stable-amd64/linux ${httpRoot}/debian/stable-amd64/linux
      cp ${tftpRoot}/debian/stable-amd64/initrd.gz ${httpRoot}/debian/stable-amd64/initrd.gz

      echo
      echo "========================================"
      echo " Downloading Slackware 15.0 32-bit"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/slackware/32bit/bzImage \
        ${slackware32Url}/kernels/huge.s/bzImage

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/slackware/32bit/initrd.img \
        ${slackware32Url}/isolinux/initrd.img

      cp ${tftpRoot}/slackware/32bit/bzImage ${httpRoot}/slackware/32bit/bzImage
      cp ${tftpRoot}/slackware/32bit/initrd.img ${httpRoot}/slackware/32bit/initrd.img

      echo
      echo "========================================"
      echo " Downloading Slackware 15.0 64-bit"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/slackware/64bit/bzImage \
        ${slackware64Url}/kernels/huge.s/bzImage

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/slackware/64bit/initrd.img \
        ${slackware64Url}/isolinux/initrd.img

      cp ${tftpRoot}/slackware/64bit/bzImage ${httpRoot}/slackware/64bit/bzImage
      cp ${tftpRoot}/slackware/64bit/initrd.img ${httpRoot}/slackware/64bit/initrd.img

      echo
      echo "========================================"
      echo " Downloading Rocky Linux 10.2"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/rocky/10/vmlinuz \
        ${rocky10Url}/images/pxeboot/vmlinuz

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/rocky/10/initrd.img \
        ${rocky10Url}/images/pxeboot/initrd.img

      cp ${tftpRoot}/rocky/10/vmlinuz ${httpRoot}/rocky/10/vmlinuz
      cp ${tftpRoot}/rocky/10/initrd.img ${httpRoot}/rocky/10/initrd.img

      echo
      echo "========================================"
      echo " Downloading AlmaLinux 10 x86_64-v3"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alma/10/vmlinuz \
        ${almaUrl}/images/pxeboot/vmlinuz

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alma/10/initrd.img \
        ${almaUrl}/images/pxeboot/initrd.img

      cp ${tftpRoot}/alma/10/vmlinuz ${httpRoot}/alma/10/vmlinuz
      cp ${tftpRoot}/alma/10/initrd.img ${httpRoot}/alma/10/initrd.img

      echo
      echo "========================================"
      echo " Installing AlmaLinux 10 x86_64-v2"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alma/10/v2/vmlinuz \
        ${almaV2Url}/images/pxeboot/vmlinuz

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alma/10/v2/initrd.img \
        ${almaV2Url}/images/pxeboot/initrd.img

      cp ${tftpRoot}/alma/10/v2/vmlinuz ${httpRoot}/alma/10/v2/vmlinuz
      cp ${tftpRoot}/alma/10/v2/initrd.img ${httpRoot}/alma/10/v2/initrd.img

      echo
      echo "========================================"
      echo " Downloading Alpine Linux x86"
      echo "========================================"

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alpine/vmlinuz-lts \
        ${alpineUrl}/releases/x86/netboot/vmlinuz-lts

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alpine/initramfs-lts \
        ${alpineUrl}/releases/x86/netboot/initramfs-lts

      ${pkgs.curl}/bin/curl -fL --retry 3 \
        --output ${tftpRoot}/alpine/modloop-lts \
        ${alpineUrl}/releases/x86/netboot/modloop-lts

      cp ${tftpRoot}/alpine/vmlinuz-lts ${httpRoot}/alpine/vmlinuz-lts
      cp ${tftpRoot}/alpine/initramfs-lts ${httpRoot}/alpine/initramfs-lts
      cp ${tftpRoot}/alpine/modloop-lts ${httpRoot}/alpine/modloop-lts

      echo
      echo "========================================"
      echo " Creating PXELINUX/iPXE configuration"
      echo "========================================"

      kernel_args="$(
        sed -n 's/^kernel bzImage //p' \
          "$netboot/netboot.ipxe/netboot.ipxe" |
          head -n 1
      )"

      if [ -z "$kernel_args" ]; then
        echo "ERROR: Could not obtain NixOS kernel arguments"
        exit 1
      fi

      cat > ${tftpRoot}/pxelinux.cfg/default <<EOF
UI menu.c32

MENU TITLE PXE Boot Menu
MENU CLEAR

DEFAULT nixos
PROMPT 0
TIMEOUT 100

LABEL nixos
    MENU LABEL NixOS 26.05 (64-bit)              x86_64
    KERNEL bzImage
    APPEND initrd=initrd $kernel_args

LABEL debian-i386
    MENU LABEL Debian 12 (32-bit)                i686
    KERNEL debian/bookworm-i386/linux
    APPEND initrd=debian/bookworm-i386/initrd.gz

LABEL debian-amd64
    MENU LABEL Debian Latest (64-bit)            amd64
    KERNEL debian/stable-amd64/linux
    APPEND initrd=debian/stable-amd64/initrd.gz

LABEL slackware32
    MENU LABEL Slackware 15.0 (32-bit)           x86
    KERNEL slackware/32bit/bzImage
    APPEND initrd=slackware/32bit/initrd.img load_ramdisk=1 prompt_ramdisk=0 rw printk.time=0 nomodeset SLACK_KERNEL=huge.s

LABEL slackware64
    MENU LABEL Slackware 15.0 (64-bit)           x86_64
    KERNEL slackware/64bit/bzImage
    APPEND initrd=slackware/64bit/initrd.img load_ramdisk=1 prompt_ramdisk=0 rw printk.time=0 nomodeset SLACK_KERNEL=huge.s

LABEL rocky
    MENU LABEL Rocky Linux 10 (64-bit)           x86_64
    KERNEL rocky/10/vmlinuz
    APPEND initrd=rocky/10/initrd.img ip=dhcp inst.repo=${rocky10Url}

LABEL alma
    MENU LABEL AlmaLinux 10 (64-bit)             x86_64
    KERNEL alma/10/vmlinuz
    APPEND initrd=alma/10/initrd.img ip=dhcp inst.repo=${almaUrl}

LABEL almav2
    MENU LABEL AlmaLinux 10 CPUv2 (64-bit)       x86_64
    KERNEL alma/10/v2/vmlinuz
    APPEND initrd=alma/10/v2/initrd.img ip=dhcp inst.repo=${almaV2Url}

LABEL alpine
    MENU LABEL Alpine Linux 3.24.2 (32-bit)      x86
    KERNEL alpine/vmlinuz-lts
    APPEND initrd=alpine/initramfs-lts modules=loop,squashfs,sd-mod,usb-storage modloop=http://172.16.16.253/alpine/modloop-lts alpine_repo=${alpineUrl}/main
EOF
      # The Tecra previously required the MAC-specific file.
      install -m 0644 \
        ${tftpRoot}/pxelinux.cfg/default \
        ${tftpRoot}/pxelinux.cfg/01-00-0e-7b-ff-fa-78

      # The Tecra also advertises this UUID during PXE.
      ln -sf \
        01-00-0e-7b-ff-fa-78 \
        ${tftpRoot}/pxelinux.cfg/cb26a680-b442-11da-8051-b05936078088

      cat > ${tftpRoot}/ipxe/menu.ipxe <<EOF
#!ipxe

:start
menu PXE Boot Menu
item --gap -- --[ OPERATING SYSTEMS ]----------------------
item nixos        NixOS 26.05 x86_64 (64-bit)
item debian-i386  Debian 12 i686 (32-bit)
item debian-amd64 Debian Latest amd64 (64-bit)
item slackware32  Slackware 15.0 x86 (32-bit)
item slackware64  Slackware 15.0 x86_64 (64-bit)
item rocky        Rocky Linux 10 x86_64 (64-bit)
item alma         AlmaLinux 10 x86_64 (64-bit)
item almav2       AlmaLinux 10 x86_64v2 (64-bit)
item alpine       Alpine Linux 3.24.2 x86 (32-bit)
item windows7     Windows 7 Professional SP1 (32-bit)
item windows10    Windows 10 Professional (32-bit)
item windows11    Windows 11 Professional (64-bit)
item --gap -- --[ RESCUE / DIAGNOSTICS ]-------------------
item sysrescue32  SystemRescue 9.03 i686 (32-bit)
item sysrescue64  SystemRescue 13.02 x86_64 (64-bit)
item memtest86    Memtest86+ 8.10
item --gap -- --[ SYSTEM ]---------------------------------
item shell        iPXE Shell
item reboot       Reboot
choose --default nixos --timeout 10000 target && goto \''${target}

:nixos
kernel ${pxebootUrl}/nixos/bzImage
initrd ${pxebootUrl}/nixos/initrd
imgargs bzImage $kernel_args
boot

:debian-i386
kernel ${pxebootUrl}/debian/bookworm-i386/linux
initrd ${pxebootUrl}/debian/bookworm-i386/initrd.gz
boot

:debian-amd64
kernel ${pxebootUrl}/debian/stable-amd64/linux
initrd ${pxebootUrl}/debian/stable-amd64/initrd.gz
boot

:slackware32
kernel ${pxebootUrl}/slackware/32bit/bzImage
initrd ${pxebootUrl}/slackware/32bit/initrd.img
imgargs bzImage load_ramdisk=1 prompt_ramdisk=0 rw printk.time=0 nomodeset SLACK_KERNEL=huge.s
boot

:slackware64
kernel ${pxebootUrl}/slackware/64bit/bzImage
initrd ${pxebootUrl}/slackware/64bit/initrd.img
imgargs bzImage load_ramdisk=1 prompt_ramdisk=0 rw printk.time=0 nomodeset SLACK_KERNEL=huge.s
boot

:rocky
kernel ${pxebootUrl}/rocky/10/vmlinuz
initrd ${pxebootUrl}/rocky/10/initrd.img
imgargs vmlinuz ip=dhcp rd.neednet=1 inst.stage2=${rocky10Url} inst.repo=${rocky10Url}
boot

:alma
kernel ${pxebootUrl}/alma/10/vmlinuz
initrd ${pxebootUrl}/alma/10/initrd.img
imgargs vmlinuz ip=dhcp rd.neednet=1 inst.stage2=${almaUrl} inst.repo=${almaUrl}
boot

:almav2
kernel ${pxebootUrl}/alma/10/v2/vmlinuz
initrd ${pxebootUrl}/alma/10/v2/initrd.img
imgargs vmlinuz ip=dhcp rd.neednet=1 inst.stage2=${almaV2Url} inst.repo=${almaV2Url}
boot

:alpine
kernel ${pxebootUrl}/alpine/vmlinuz-lts
initrd ${pxebootUrl}/alpine/initramfs-lts
imgargs vmlinuz-lts modules=loop,squashfs,sd-mod,usb-storage modloop=http://172.16.16.253/alpine/modloop-lts alpine_repo=${alpineUrl}/main
boot

:windows7
kernel ${pxebootUrl}/windows/wimboot/wimboot
initrd ${pxebootUrl}/windows/7/x86/bootmgr bootmgr
initrd ${pxebootUrl}/windows/7/x86/boot/bcd BCD
initrd ${pxebootUrl}/windows/7/x86/boot/boot.sdi boot.sdi
initrd ${pxebootUrl}/windows/7/x86/sources/boot.wim boot.wim
initrd ${pxebootUrl}/windows/7/deploy/wget.exe wget.exe
initrd ${pxebootUrl}/windows/7/deploy/winpeshl.ini winpeshl.ini
initrd ${pxebootUrl}/windows/7/deploy/kick7.cmd kick7.cmd
boot

:windows10
kernel ${pxebootUrl}/windows/wimboot/wimboot
initrd ${pxebootUrl}/windows/10/x86/bootmgr bootmgr
initrd ${pxebootUrl}/windows/10/x86/boot/bcd BCD
initrd ${pxebootUrl}/windows/10/x86/boot/boot.sdi boot.sdi
initrd ${pxebootUrl}/windows/10/x86/sources/boot.wim boot.wim
initrd ${pxebootUrl}/windows/10/deploy/wget.exe wget.exe
initrd ${pxebootUrl}/windows/10/deploy/winpeshl.ini winpeshl.ini
initrd ${pxebootUrl}/windows/10/deploy/kick10.cmd kick10.cmd
boot

:windows11
kernel ${pxebootUrl}/windows/wimboot/wimboot
initrd ${pxebootUrl}/windows/11/x86_64/bootmgr bootmgr
initrd ${pxebootUrl}/windows/11/x86_64/boot/bcd BCD
initrd ${pxebootUrl}/windows/11/x86_64/boot/boot.sdi boot.sdi
initrd ${pxebootUrl}/windows/11/x86_64/sources/boot.wim boot.wim
initrd ${pxebootUrl}/windows/11/deploy/wget.exe wget.exe
initrd ${pxebootUrl}/windows/11/deploy/winpeshl.ini winpeshl.ini
initrd ${pxebootUrl}/windows/11/deploy/kick11.cmd kick11.cmd
boot

:sysrescue32
kernel ${pxebootUrl}/systemrescue/sysresccd/boot/i686/vmlinuz
initrd ${pxebootUrl}/systemrescue/sysresccd/boot/i686/sysresccd.img
imgargs vmlinuz archisobasedir=sysresccd ip=dhcp archiso_http_srv=${pxebootUrl}/systemrescue/
boot

:sysrescue64
kernel ${pxebootUrl}/systemrescue/sysresccd/boot/x86_64/vmlinuz
initrd ${pxebootUrl}/systemrescue/sysresccd/boot/x86_64/sysresccd.img
imgargs vmlinuz archisobasedir=sysresccd ip=dhcp archiso_http_srv=${pxebootUrl}/systemrescue/
boot

:memtest86
kernel ${pxebootUrl}/memtest/mt86p_810_i586
boot

:shell
shell

:reboot
reboot
EOF
      echo
      echo "========================================"
      echo " PXE/iPXE installation complete"
      echo "========================================"
    '';
  };

  networking.firewall.allowedUDPPorts = [
    69
  ];

  networking.firewall.allowedUDPPortRanges = [
    {
      from = 32768;
      to = 60999;
    }
  ];

  environment.systemPackages = with pkgs; [
    wimlib
  ];
}
