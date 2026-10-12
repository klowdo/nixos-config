{...}: {
  flake.modules.homeManager.spotify-player = {
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
