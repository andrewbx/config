{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      irssi
      eza
      vivid
      vim
      git
      btop
      htop
      inetutils
      qrencode
      jq
      wget
      gnupg
      tree
      ripgrep
      curl
      oh-my-zsh
      tshark
      mtr
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nmap
      zstd
    ];
  };
}
