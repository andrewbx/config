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
      "bitwarden-cli"
      "fs-uae"
      "gemini-cli"
      "gnupg"
      "mise"
      "openssl@4"
    ];

    taps = [
      "cloudflare/cloudflare"
    ];
  };
}
