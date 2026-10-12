{
  flake.modules.nixos.steam = {pkgs, ...}: {
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

    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      gamescope
    ];
  };
}
