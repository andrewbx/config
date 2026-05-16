{
  pkgs,
  primaryUser,
  ...
}:
{
  networking.hostName = "macbook-one";
  networking.search = [ "devnull.uk" ];
  networking.knownNetworkServices = [
    "Wi-Fi"
    "Ethernet"
    "USB 10/100/1G/2.5G LAN"
    "USB 10/100/1G LAN"
    "USB 10/100/1000 LAN"
    "USB 10/100 LAN"
    "Thunderbolt Bridge"
  ];

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
