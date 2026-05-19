_: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
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
}
