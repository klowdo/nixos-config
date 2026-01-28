{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.communication.vesktop;
in {
  options.features.communication.vesktop.enable = mkEnableOption "enable Vesktop Discord client";

  config = mkIf cfg.enable {
    programs.vesktop = {
      enable = true;
      settings = {
        # Discord branch
        discordBranch = "stable";

        # System tray and window behavior
        tray = true;
        minimizeToTray = true;
        clickTrayToShowHide = true;

        # Window customization
        customTitleBar = true;
        enableMenu = true;
        staticTitle = false;

        # Performance
        hardwareAcceleration = true;
        disableSmoothScroll = false;

        # Links and external behavior
        openLinksWithElectron = false;

        # Audio settings
        audio = {
          workaround = false;
          deviceSelect = true;
        };

        # Splash screen
        enableSplashScreen = true;
        splashTheming = true;
      };

      vencord = {
        useSystem = true;
        settings = {
          # Enable plugins
          plugins = {
            FakeNitro = {
              enabled = true;
            };
          };
        };
      };
    };
  };
}
