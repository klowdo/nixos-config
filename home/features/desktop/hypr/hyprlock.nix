{config, lib, pkgs, ...}: let
  # Image paths from lib directory
  wallpaperPath = ../../../../lib/nix-wallpaper-nineish-catppuccin-macchiato.png;
  userPhotoPath = ../../../../lib/felix_evolve.jpg;

  # Music widget paths
  musicArtCache = "${config.home.homeDirectory}/.config/hypr/scripts/music.webp";
  musicScript = "${config.home.homeDirectory}/.config/hypr/scripts/hyprlock-music.sh";
in {
  programs.hyprlock = {
    enable = true;

    settings = {
      # GENERAL
      general = lib.mkForce {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = false;
      };

      # AUTHENTICATION - Fingerprint configuration
      auth = {
        fingerprint = {
          enabled = true;
          ready_message = "Scan fingerprint to unlock";
          present_message = "Scanning...";
        };
      };

      # BACKGROUND
      background = lib.mkForce [
        {
          monitor = "";
          path = "${wallpaperPath}";
          blur_passes = 2;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      # INPUT FIELD
      input-field = lib.mkForce [
        {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(100, 114, 125, 0.4)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          font_family = "SF Pro Display Bold";
          placeholder_text = ''<i><span foreground="##ffffff99">Enter Pass</span></i>'';
          fail_text = ''<i>$PAMFAIL</i>'';
          hide_input = false;
          position = "0, -225";
          halign = "center";
          valign = "center";
        }
      ];

      label = lib.mkForce [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 130;
          font_family = "SF Pro Display Bold";
          position = "0, 240";
          halign = "center";
          valign = "center";
        }

        # Day-Month-Date
        {
          monitor = "";
          text = ''cmd[update:1000] echo -e "$(date +"%A, %d %B")"'';
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 30;
          font_family = "SF Pro Display Bold";
          position = "0, 105";
          halign = "center";
          valign = "center";
        }

        # USER
        {
          monitor = "";
          text = "Hi, $USER";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          font_family = "SF Pro Display Bold";
          position = "0, -130";
          halign = "center";
          valign = "center";
        }

        # AUTHENTICATION STATUS - Shows fingerprint scanning or password prompt
        {
          monitor = "";
          text = "Scan fingerprint or enter password";
          color = "rgba(150, 205, 251, 0.85)";
          font_size = 14;
          font_family = "SF Pro Display Medium";
          position = "0, -300";
          halign = "center";
          valign = "center";
        }

        # MUSIC - Song title
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(${musicScript} --title)\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 16;
          font_family = "SF Pro Display Heavy";
          position = "55, 138";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Player source
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(${musicScript} --player)\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 13;
          font_family = "SF Pro Display Bold";
          position = "205, 45";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Artist name
        {
          monitor = "";
          text = "cmd[update:1000] echo \"󰠃  $(${musicScript} --artist)\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 12;
          font_family = "SF Pro Display Semibold";
          position = "55, 118";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Previous button
        {
          monitor = "";
          text = "󰒮";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          onclick = "${pkgs.playerctl}/bin/playerctl previous";
          position = "-5, 55";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Play/Pause button
        {
          monitor = "";
          text = "cmd[update:1000] ${musicScript} --status";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          onclick = "${pkgs.playerctl}/bin/playerctl play-pause";
          position = "55, 55";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Next button
        {
          monitor = "";
          text = "󰒭";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          onclick = "${pkgs.playerctl}/bin/playerctl next";
          position = "110, 55";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Current position
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(${musicScript} --position)\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 10;
          font_family = "SF Pro Display Medium";
          position = "-100, 95";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Total length
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(${musicScript} --length)\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 10;
          font_family = "SF Pro Display Medium";
          position = "210, 95";
          halign = "center";
          valign = "bottom";
        }

        # MUSIC - Progress bar
        {
          monitor = "";
          text = "cmd[update:1000] ${musicScript} --progress-bar";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 12;
          font_family = "SF Pro Display Medium";
          position = "55, 95";
          halign = "center";
          valign = "bottom";
        }
      ];

      # Images: Profile photo + Album art
      image = lib.mkForce [
        # Profile Photo
        {
          monitor = "";
          path = "${userPhotoPath}";
          border_color = "0xffdddddd";
          border_size = 0;
          size = 120;
          rounding = -1;
          rotate = 0;
          reload_time = -1;
          reload_cmd = "";
          position = "0, -20";
          halign = "center";
          valign = "center";
        }

        # Album Art
        {
          monitor = "";
          path = musicArtCache;
          size = 100;
          rounding = 5;
          border_size = 3;
          border_color = "rgba(216, 222, 233, 0.70)";
          rotate = 0;
          reload_time = 2;
          reload_cmd = "${musicScript} --art";
          position = "-180, 57";
          halign = "center";
          valign = "bottom";
        }
      ];

      # Music widget background box
      shape = lib.mkForce [
        {
          monitor = "";
          color = "rgba(100, 114, 125, 0.4)";
          size = "500, 140";
          rounding = 10;
          position = "0, 40";
          halign = "center";
          valign = "bottom";
          zindex = 0;
        }
      ];
    };
  };
}
