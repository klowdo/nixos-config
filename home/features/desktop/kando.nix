{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.kando;
in {
  options.features.desktop.kando.enable =
    mkEnableOption "Kando cross-platform pie menu";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kando
    ];
  };
}
