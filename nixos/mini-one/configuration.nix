# /etc/nixos/configuration.nix

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./filesystem/filesystem.nix
      ./networking/network.nix
      ./networking/ssh.nix
      ./networking/snmp.nix
      ./networking/pxeboot.nix
      ./security/security-os.nix
      ./security/security-tools.nix
      ./virtualisation/virtualisation.nix
      ./containers/containers.nix
      ./console/shell.nix
      ./applications/technitium.nix
      ./applications/forgejo.nix
      ./applications/srcds.nix
      ./applications/sourcemod.nix
      ./applications/nginx.nix
      ./sync/sync-containers.nix
      ./sync/sync-forgejo.nix
    ];

  # Nix Settings.
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    builders-use-substitutes = true;
    max-substitution-jobs = 4;
    max-jobs = 2;
    cores = 1;
    trusted-users = [ "root" "andrew" "build" ];
    extra-platforms = [ "aarch64-linux" ];
  };

  # Lower the priority for Nix Daemon.
  systemd.services.nix-daemon.serviceConfig.Nice = 10;

  # Generation history.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
  };

  # Bootloader.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Other boot options.
  boot.tmp.useTmpfs = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Blacklist kernel modules.
  boot.blacklistedKernelModules = [ "snd_hda_intel" "btusb" "bluetooth" ];

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
  users.users.andrew = {
    isNormalUser = true;
    uid = 1027;
    description = "Andrew";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqryoaEsOOsEMlIM8pueomqeBj15MaGZuhAs2wwtUxX"
    ];
  };

  # Define a build user account to assist with remote builds.
  users.users.build = {
    isNormalUser = true;
    uid = 1028;
    description = "NixOS remote build user";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBo8AnsYqdpoKCvaOpriZ7UpWfXR54iqKTdV680Df8FF"
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
    iw
    dmidecode
    pciutils
    inxi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Performance and Storage Optimizations.
  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 25;
  };
  documentation.nixos.enable = false;

  # Enable write caching.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sda", RUN+="${pkgs.hdparm}/bin/hdparm -W1 /dev/sda"
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
    dates = "Sun 05:30";
    rebootWindow = {
      lower = "05:30";
      upper = "06:30";
    };
    flake = null;
  };
}
