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
      # nix shell
      packages.${system}.default = pkgs.buildEnv {
        name = "tools";
        paths = with pkgs; [
          git
          curl
          jq
          ripgrep
        ];
      };

      # nix develop
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          jq
          btop
          htop
          automake
          libtool
          gnupg
          openssl
          pkg-config
          inetutils
          libpsl
          qemu
          pyenv
          uv
          starship
          zsh
          bandit
          checkov
          hadolint
          isort
          pre-commit
          shellcheck
          gitleaks
          mypy
          pylint
          ruff
          perlPackages.PerlTidy
          perlcritic
        ];

        nativeBuildInputs = with pkgs;
          let
            devpython = pkgs.python3.withPackages
              (packages: with packages; [ virtualenv pip setuptools wheel ]);
          in [ devpython ];

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
