{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.media.pinta;
in {
  options.features.media.pinta.enable = mkEnableOption "enable pinta";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.pinta
    ];
  };
}
