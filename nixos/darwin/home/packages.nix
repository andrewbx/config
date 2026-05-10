{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      vim
      git
      btop
      htop
      jq
      wget
      gnupg
      tree
      ripgrep
      curl
      oh-my-zsh
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];
  };
}
