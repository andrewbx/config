{
  pkgs,
  primaryUser,
  ...
}:
{
  networking.hostName = "Apple-MacBook-Air";

  # Host specific homebrew casks.
  homebrew.casks = [
    # "slack"
  ];

  # Host specific home-manager configuration.
  home-manager.users.${primaryUser} = {
    home.packages = with pkgs; [
      graphite-cli
    ];

    programs = {
      zsh = {
        initContent = ''
          # Source shell functions.
          # source ${./shell-functions.sh}
        '';
      };
    };
  };

  home-manager.backupFileExtension = "backup";
}
