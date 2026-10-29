# /etc/nixos/configuration.nix

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./filesystem/filesystem.nix
      ./networking/network.nix
      ./networking/snmp.nix
      ./security/security-os.nix
      ./security/security-tools.nix
      ./console/shell.nix
      ./applications/technitium.nix
#     ./virtualisation/virtualisation.nix
#     ./containers/containers.nix
    ];

  # Nix Settings.
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    builders-use-substitutes = true;
    max-jobs = 0;
    max-substitution-jobs = 2;
    cores = 1;
  };

  # Lower the priority for Nix Daemon.
  systemd.services.nix-daemon.serviceConfig = {
    Nice = 10;
    memoryHigh = "700M";
  };

  # Generation history.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
  };

  # Boot.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [
    "cma=16M"
    "reboot=w"
    "brcmfmac.feature_disable=0"
  ];
  boot.tmp.useTmpfs = true;

  # Blacklist kernel modules.
  boot.blacklistedKernelModules = [ "snd_hda_intel" "btusb" "bluetooth" ];

  # Ensure correct firmware package. 
  hardware.enableRedistributableFirmware = true;

  # Disable Bluetooth.
  hardware.bluetooth.enable = false;

  # systemd journald.
  services.journald.extraConfig = ''
    Storage=volatile
  '';

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  # Enable COSMIC.
  services.desktopManager.cosmic.enable = false;
  services.displayManager.cosmic-greeter.enable = false;

  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap.
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable/Disable sound with pipewire.
  hardware.alsa.enable = false;
  services.pulseaudio.enable = false;
  security.rtkit.enable = false;
  services.pipewire = {
    enable = false;
    alsa.enable = false;
    alsa.support32Bit = false;
    pulse.enable = false;
    jack.enable = false;
    wireplumber.enable = false;
  };

  # Enable iperf3 server.
  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rpi-admin = {
    isNormalUser = true;
    description = "Raspberry Pi Admin";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqryoaEsOOsEMlIM8pueomqeBj15MaGZuhAs2wwtUxX"
    ];
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    lm_sensors
    iotop
    sqlite
    bat
    screen
    btop
    eza
    vivid
    nerd-fonts.jetbrains-mono
    git
    htop
    hdparm
    jq
    zip
    unzip
    vim
    smartmontools
    inxi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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

  # Performance and Storage Optimizations.
  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
  };
  documentation.nixos.enable = false;
  systemd.services.sshd.serviceConfig.ManagedOOMPreference = "avoid";

  nix.settings.trusted-users = [ "root" "rpi-admin" ];

  # Enable write caching.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="mmcblk0", RUN+="${pkgs.hdparm}/bin/hdparm -W1 /dev/mmcblk0"
  '';

  # Setup rsyslog and forward to log server.
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = ''
    *.* action(
      type="omfwd"
      target="172.16.16.253"
      port="514"
      protocol="udp"
      action.resumeRetryCount="100"
      queue.type="linkedList"
      queue.size="10000"
    )
  '';

  # This value determines the NixOS release.
  system.stateVersion = "25.11";

  # Auto Update and Reboot.
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    operation = "switch";
    dates = "Sun 04:00";
    rebootWindow = {
      lower = "04:00";
      upper = "05:00";
    };
    flake = null;
  };

  # Handoff build tasks to a remote builder
  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        system = "aarch64-linux";
        sshUser = "build";
        sshKey = "/root/.ssh/nix-build";
        maxJobs = 1;
        protocol = "ssh-ng";
        hostName = "mini-one.devnull.uk";
        supportedFeatures = [ ];
      }
    ];
  };
}

