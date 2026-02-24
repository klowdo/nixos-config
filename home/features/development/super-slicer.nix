{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.super-slicer;
in {
  options.features.development.super-slicer.enable = mkEnableOption "enable super-slicer 3D printing slicer";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.super-slicer
    ];
  };
}
