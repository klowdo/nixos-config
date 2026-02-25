{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = false;
    gamescopeSession.enable = true;
    extraPackages = with pkgs; [gamescope];
    package = pkgs.steam.override {
      extraEnv = {
        STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
      };
    };
  };

  programs.gamemode.enable = true;

  # Enable 32-bit graphics support for Steam
  hardware.graphics.enable32Bit = true;

  # Add gamescope and other useful gaming packages
  environment.systemPackages = with pkgs; [
    gamescope
  ];
}
