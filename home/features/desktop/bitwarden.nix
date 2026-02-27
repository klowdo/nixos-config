{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.bitwarden;
in {
  options.features.desktop.bitwarden.enable =
    mkEnableOption "bitwarden desktop application";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
    ];
  };
}
