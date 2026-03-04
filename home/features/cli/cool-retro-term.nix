{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.cool-retro-term;
in {
  options.features.cli.cool-retro-term.enable = mkEnableOption "enable cool-retro-term terminal emulator";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [cool-retro-term];
  };
}
