{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.gaming.heroic;
in {
  options.features.gaming.heroic.enable = mkEnableOption "enable heroic games launcher for Epic, GOG, and Amazon Gaming";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      heroic
    ];
  };
}
