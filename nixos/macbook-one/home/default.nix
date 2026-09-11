{ primaryUser, ... }:
{
  imports = [
    ./packages.nix
    ./git.nix
    ./nano.nix
    ./neovim.nix
    ./shell.nix
  ];

  home = {
    username = primaryUser;
    stateVersion = "25.11";
    sessionVariables = {
      # Shared environment variables.
    };

    file.".hushlogin".text = "";
  };
}
