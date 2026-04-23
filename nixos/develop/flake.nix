# flake.nix:

{
  description = "Nix shell development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          jq
          btop
          htop
          nmap
          irssi
          automake
          libtool
          gnupg
          openssl
          pkg-config
          bind
          iperf3
          inetutils
          libpsl
          qemu
          pyenv
          uv
          starship
          zsh
        ];

        shellHook = ''
          echo "[x] Nix development shell activated"

          # Spawn ZSH
          if [ -z "$ZSH_VERSION" ]; then
            export SHELL=${pkgs.zsh}/bin/zsh
            exec ${pkgs.zsh}/bin/zsh
          fi

          # Prevent OpenSSL conflicts
          export LDFLAGS="-L${pkgs.openssl.out}/lib"
          export CPPFLAGS="-I${pkgs.openssl.dev}/include"
        '';
      };
    };
}
