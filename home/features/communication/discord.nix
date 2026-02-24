{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.communication.discord;
in {
  options.features.communication.discord.enable = mkEnableOption "enable discord chat";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
    ];
  };
}
