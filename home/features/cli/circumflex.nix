{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.circumflex;
in {
  options.features.cli.circumflex.enable = mkEnableOption "enable circumflex Hacker News TUI";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [circumflex];
  };
}
