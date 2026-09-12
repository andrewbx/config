# /etc/nixos/configuration.nix

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./filesystem.nix
      ./network.nix
      ./security-os.nix
      ./security-tools.nix
      ./technitium.nix
    ];

  # Nix Settings.
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 2;
    cores = 2;
  };

  # Generation history.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +10";
  };

  # Bootloader.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;
  boot.kernelModules = [ "kvm-intel" ];

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
    description = "Andrew";
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
    irssi
    screen
    btop
    curl
    dnsutils
    eza
    vivid
    nerd-fonts.jetbrains-mono
    git
    htop
    hdparm
    jq
    (lib.hiPrio pkgs.nettools)
    unzip
    vim
    wget
    zsh
    iperf3
    smartmontools
    iw
  ];

  # Z-Shell configuration.
  programs.zsh = {
    enable = true;
    enableLsColors = true;
    autosuggestions.enable = true;
    zsh-autoenv.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "gianu";
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "npm"
        "node"
        "history"
        "rust"
      ];
    };
    shellAliases = {
      ls = "eza --group --group-directories-first --icons=auto";
      ll = "eza -lh --group --group-directories-first --icons=auto --git";
      la = "eza -lah --group --group-directories-first --icons=auto";
      lt = "eza --tree --level=2 --group --group-directories-first --icons=auto";
    };
  };

  # Bash shell configuration.
  programs.bash.shellAliases = {
    ls = "eza --group --group-directories-first --icons=auto";
    ll = "eza -lh --group --group-directories-first --icons=auto --git";
    la = "eza -lah --group --group-directories-first --icons=auto";
    lt = "eza --tree --level=2 --group --group-directories-first --icons=auto";
  };

  # Add zsh to /etc/shells so it's recognized.
  environment.shells = with pkgs; [ zsh ];
  environment.interactiveShellInit = ''
    export EZA_COLORS="da=38;5;245:uu=38;5;245:gu=38;5;245";
    export LS_COLORS="$(vivid generate nord)"
  '';

  # Set Zsh as default user shell.
  users.defaultUserShell = pkgs.zsh;

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
    memoryPercent = 25;
  };
  documentation.nixos.enable = false;

  nix.settings.trusted-users = [ "root" "andrew" ];

  # Enable write caching.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sda", RUN+="${pkgs.hdparm}/bin/hdparm -W1 /dev/sda"
  '';

  # Setup rsyslog and forward to log server.
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = ''
    module(load="imfile")
    module(load="imuxsock")
    module(load="imjournal" StateFile="imjournal.state")
    module(load="omfwd")

    *.* action(
      type="omfwd"
      target="172.16.16.10"
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
    allowReboot = true;
    dates = "05:30";
    rebootWindow = {
      lower = "05:00";
      upper = "06:00";
    };
    flake = null;
  };
}
