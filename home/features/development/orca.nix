{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.orca;
in {
  options.features.development.orca.enable = mkEnableOption "enable orca 3D printing slicer";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.orca-slicer
    ];
  };
}
