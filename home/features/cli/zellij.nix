{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.zellij;
in {
  options.features.cli.zellij.enable = mkEnableOption "enable zellij terminal multiplexer";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [zellij];
  };
}
