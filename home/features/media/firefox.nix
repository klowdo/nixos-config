{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.media.firefox;
in {
  options.features.media.firefox.enable = mkEnableOption "enable firefox browser";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
    };
  };
}
