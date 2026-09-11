{ pkgs, ... }: {
  # Install the nano package.
  home.packages = [ pkgs.nano ];

  # Manually create the .nanorc file.
  home.file.".nanorc".text = ''
    set tabsize 4
    set tabstospaces
    set autoindent
    set constantshow
    include "${pkgs.nano}/share/nano/*.nanorc"
  '';
}
