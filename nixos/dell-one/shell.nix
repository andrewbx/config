{ config, pkgs, ... }:

let
  shellAliases = {
    ls = "eza --group --group-directories-first --icons=auto";
    ll = "eza -lh --group --group-directories-first --icons=auto --git";
    la = "eza -lah --group --group-directories-first --icons=auto";
    lt = "eza --tree --level=2 --group --group-directories-first --icons=auto";
    dev = "/work/Dev/git";
  };
in
{
  programs.zsh.shellAliases = shellAliases;
  programs.bash.shellAliases = shellAliases;

  environment.systemPackages = with pkgs; [
    zsh
    bash
  ];

  # Shell(s) configuration.
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
  };

  # Add zsh to /etc/shells so it's recognized.
  environment.shells = with pkgs; [ zsh ];
  environment.interactiveShellInit = ''
    export EZA_COLORS="da=38;5;245:uu=38;5;245:gu=38;5;245";
    export LS_COLORS="$(vivid generate nord)"
  '';

  # Set Zsh as default user shell.
  users.defaultUserShell = pkgs.zsh;
}
