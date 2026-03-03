{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.media.zathura;
in {
  options.features.media.zathura.enable = mkEnableOption "enable zathura";

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
    };
  };
}
