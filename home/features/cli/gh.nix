{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.gh;
in {
  options.features.cli.gh.enable = mkEnableOption "enable github (gh) cli tool";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gh
      gh-dash
    ];
  };
}
