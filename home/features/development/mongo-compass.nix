{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.mongo-compass;
in {
  options.features.development.mongo-compass.enable = mkEnableOption "enable mongo compass";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.mongodb-compass
      pkgs.mongodb-tools
      pkgs.mongosh
    ];
  };
}
