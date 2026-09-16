{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.munder-difflin;
in {
  options.features.desktop.munder-difflin.enable =
    mkEnableOption "munder difflin multi-agent harness";

  config = mkIf cfg.enable {
    home.packages = [pkgs.munder-difflin];
  };
}
