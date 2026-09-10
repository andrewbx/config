{ config, pkgs, lib, ... }:

{
  services.displayManager.gdm = {
    enable = true;

    settings = {
      daemon = {
        AutomaticLoginEnable = false;
      };
    };
  };

  # Enable the native host connector service
  services.gnome.gnome-browser-connector.enable = true;

  # Link the browser connector files globally so Brave can see them
  environment.etc."chromium/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source = 
    "${pkgs.gnome-browser-connector}/etc/chromium/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

  services.desktopManager.gnome.enable = true;
  services.desktopManager.cosmic.enable = false;
  services.displayManager.cosmic-greeter.enable = false;

  # Force GNOME's Login Manager (GDM) to load the Pixel Pusher backdrop at startup
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.shell]
    always-show-log-out=true
  '';

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.no-overview
    gnomeExtensions.dash-to-dock
  ];

  programs.dconf.profiles.user.databases = [
    {
      lockAll = false;

      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            pkgs.gnomeExtensions.dash-to-dock.extensionUuid           
          ];
        };
      };
    }
  ];
}
