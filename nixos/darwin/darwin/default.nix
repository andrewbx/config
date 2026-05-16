{
  pkgs,
  inputs,
  self,
  primaryUser,
  ...
}:
{
  imports = [
    ./homebrew.nix
    ./settings.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  # Nix configuration.
  nix = {
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://nix-community.cachix.org"
      ];
      
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSH9qf2bJr9rJrj9kYl9z2H5r+4n2cYk5f3k="
      ];

      gc-automatic = true;
      gc-dates = "daily";
      gc-keep-outputs = false;
      gc-keep-derivations = false;
    };

    extraOptions = ''
      min-free = 1073741824
      max-free = 10737418240
    '';

    # Required if determinate systems version is used.
    enable = false;
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Homebrew installation manager.
  nix-homebrew = {
    user = primaryUser;
    enable = true;
    autoMigrate = true;
  };

  # Configuration for home-manager.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${primaryUser} = {
      imports = [
        ../home
      ];
    };
    extraSpecialArgs = {
      inherit inputs self primaryUser;
    };
  };

  # MacOS-specific settings.
  system.primaryUser = primaryUser;
  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    shell = pkgs.zsh;
  };

  environment = {
    systemPath = [
      "/opt/homebrew/bin"
    ];
    pathsToLink = [ "/Applications" ];
  };

  environment.interactiveShellInit = ''
    export EZA_COLORS="da=38;5;245:uu=38;5;245:gu=38;5;245";
    export LS_COLORS="$(vivid generate nord)"
  '';
}
