{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.freecad;
in {
  options.features.development.freecad.enable = mkEnableOption "enable freecad";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.freecad-wayland
    ];
  };
}
