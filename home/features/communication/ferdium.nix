{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.communication.ferdium;
in {
  options.features.communication.ferdium.enable = mkEnableOption "enable ferdium";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ferdium
    ];
  };
}
