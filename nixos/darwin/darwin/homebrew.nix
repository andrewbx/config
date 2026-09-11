{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    global = {
      brewfile = false;
    };
    
    casks = [
      "balenaetcher"
      "brave-browser"
      "bitwarden"
      "ccleaner"
      "eqmac"
      "fs-uae-emulator"
      "fs-uae-launcher"
      "grok-build"
      "iterm2"
      "steam"
      "synology-drive"
      "utm"
      "winbox"
      "wireshark-app"
      "logi-options+"
      "vscodium"
    ];

    brews = [
      "ancient"
      "bitwarden-cli"
      "container"
      "e2fsprogs"
      "fs-uae"
      "gnupg"
      "lhasa"
      "mise"
      "openssl@4"
      "sdl3"
      "sdl2-compat"
      "sevenzip"
      "uade"
    ];

    taps = [
      "cloudflare/cloudflare"
    ];
  };
}
