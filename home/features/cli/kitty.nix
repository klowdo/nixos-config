{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.kitty;
in {
  options.features.cli.kitty.enable = mkEnableOption "enable kitty terminal";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        allow_remote_control = "yes";
        font_size = 12;
      };
      shellIntegration = {
        enableZshIntegration = true;
      };
      # enableZshIntegration = true;
      # confirm_os_window_close = 0;
      # dynamic_background_opacity = true;
      # enable_audio_bell = false;
      # mouse_hide_wait = "-1.0";
    };
  };
}
