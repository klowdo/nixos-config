{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.hardware.bluetooth;
in {
  options.features.hardware.bluetooth.enable = mkEnableOption "enable bluetuith bluetooth TUI";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [bluetuith];
  };
}
