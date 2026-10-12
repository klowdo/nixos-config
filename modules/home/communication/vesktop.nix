{...}: {
  flake.modules.homeManager.vesktop = {
    programs.vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";

        tray = true;
        minimizeToTray = true;
        clickTrayToShowHide = true;

        customTitleBar = true;
        enableMenu = true;
        staticTitle = false;

        hardwareAcceleration = true;
        disableSmoothScroll = false;

        openLinksWithElectron = false;

        audio = {
          workaround = false;
          deviceSelect = true;
        };

        enableSplashScreen = true;
        splashTheming = true;
      };

      vencord = {
        useSystem = true;
        settings = {
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
