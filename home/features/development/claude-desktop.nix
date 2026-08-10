{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.claude-desktop;
in {
  options.features.development.claude-desktop.enable = mkEnableOption "enable claude-desktop";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.claude-desktop
    ];
  };
}
