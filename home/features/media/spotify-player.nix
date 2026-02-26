{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.media.spotify-player;
in {
  options.features.media.spotify-player.enable = mkEnableOption "enable spotify-player tui player";

  config = mkIf cfg.enable {
    programs.spotify-player = {
      enable = true;
      settings = {
        playback_window_position = "Top";
        copy_command = {
          command = "wl-copy";
          args = [];
        };
        device = {
          audio_cache = false;
          normalization = false;
        };
      };
    };
  };
}
