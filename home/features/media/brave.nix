{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.media.brave;
in {
  options.features.media.brave.enable = mkEnableOption "enable Brave browser";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [brave];
  };
}
