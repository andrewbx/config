# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./security-os.nix
      ./security-tools.nix
      ./virtualisation.nix
      ./nvidia.nix
      ./amiga.nix
      ./gnome.nix
    ];

  # Nix Settings.
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Generation history.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +10";
  };

  # GRUB boot settings.
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sdb"; 
      useOSProber = true;
      splashImage = null;
      backgroundColor = null;

      theme = pkgs.stdenv.mkDerivation {
        pname = "distro-grub-themes";
        version = "3.1";
        src = pkgs.fetchFromGitHub {
          owner = "AdisonCavani";
          repo = "distro-grub-themes";
          rev = "v3.1";
          hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
        };
        installPhase = "cp -r customize/nixos $out";
      };
    };

    initrd.verbose = false;
    consoleLogLevel = 3;
    kernelParams = [ 
      "quiet" 
      "splash" 
      "boot.shell_on_fail" 
      "rd.systemd.show_status=auto" 
      "udev.log_level=3"
    ];
  };

  boot.tmp.useTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_7_2;

  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=GB
    options rtw89_core disable_lps_deep=y
    options rtw89_usb disable_aspm=y
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.wirelessRegulatoryDatabase = true;
  hardware.usb-modeswitch.enable = true;

  # Enable networking.
  networking = {
    networkmanager = {
      enable = true;
      settings = {
        device = {
          "wifi.scan-rand-mac-address" = "no";
        };
        connection = {
          "wifi.cloned-mac-address" = "permanent";
        };
      };
    };

    hostName = "dell-one";
    domain = "devnull.uk";
  };

  # systemd resolver.
  services.resolved.enable = false;
  networking.resolvconf.enable = true;

  # systemd journald.
  services.journald.extraConfig = ''
    Storage=volatile
  '';

  systemd.services.systemd-udev-settle.enable = false;
  systemd.targets.network-online.enable = true;
  systemd.services.NetworkManager-wait-online.enable = true;

  systemd.services.display-manager = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

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
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig = {
      "10-mtk-flfr" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_output.usb-Soundcraft_Soundcraft_Signature_12_MTK.*"; }
            ];
            actions = {
              "update-props" = {
                "audio.position" = "AUX0,AUX1,AUX2,AUX3,AUX4,AUX5,AUX6,AUX7,AUX8,AUX9,FL,FR";
              };
            };
          }
        ];
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."andrew" = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" "storage" ];
    packages = with pkgs; [
      #
    ];
  };

  # Install firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    iw
    iperf
    vim
    wget
    brave
    usbutils
    bitwarden-desktop
    bitwarden-cli
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
    ddrescue
    pavucontrol
    qpwgraph
    alsa-utils
    pulseaudio
    wireplumber
    ntfs3g
    exfatprogs
    vscodium
    neovim
    file
    inetutils
    pciutils
    udftools
    gparted
    python3
    python3Packages.pip
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
    enable = false;
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

  # Actually load the drivers
  boot.kernelModules = [ "udf" "isofs" ];
  boot.initrd.availableKernelModules = [ "udf" "isofs" ];

  # Enable kernel support for NTFS, FAT32 and UDF
  boot.supportedFilesystems = [ "udf" "iso9660" "ntfs" "vfat" ];

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

  nix.settings.trusted-users = [ "root" "andrew" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
