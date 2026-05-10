{ self, ... }:
{
  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # System defaults and preferences.
  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;
    startup.chime = true;

    defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        mru-spaces = false;
        show-recents = false;
        orientation = "bottom";
      };

      controlcenter.BatteryShowPercentage = true;
      WindowManager.EnableStandardClickToShowDesktop = false;
      
      CustomUserPreferences = {
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
          AppleInterfaceStyle = "Dark";
          "com.apple.swipescrolldirection" = 0;
        };
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          ScheduleFrequency = 1;
          AutomaticDownload = 1;
          CriticalUpdateInstall = 1;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.print.PrintingPrefs" = {
          "Quit When Finished" = true;
        };
        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
        "com.apple.ImageCapture".disableHotPlug = true;
        "com.apple.commerce".AutoUpdate = true;
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.brave.Browser" = {
          IncognitoModeAvailability = 1;
          TorDisabled = false;
          BraveAIEnabled = false;
          BraveAIChatEnabled = false;
          BraveLeoEnabled = false;
          BraveChatEnabled = false;
          BraveWalletDisabled = true;
          CryptoWalletEnabled = false;
          BraveRewardsDisabled = true;
          BraveVPNDisabled = true;
          PasswordManagerEnabled = false;
        };
        "com.googlecode.iterm2" = {
          ShowFullScreenTabBar = true;
          SoundForEsc = false;
          StatusBarPosition = 1;
          StretchTabsToFillBar = false;
          UseBorder = 1;
        };
      };
      
      finder = {
        AppleShowAllFiles = false;
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
        _FXShowPosixPathInTitle = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
      };

      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
      };
    };
  };
}
