{
  lib,
  pkgs,
  ...
}: let
  increments = "5";

  sound-change = pkgs.writeShellScriptBin "sound-change" ''
    [[ $1 == "mute" ]] && wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    [[ $1 == "up" ]] && wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ ''${2-${increments}}%+
    [[ $1 == "down" ]] && wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ ''${2-${increments}}%-
    [[ $1 == "set" ]] && wpctl set-volume --limit=1.5 @DEFAULT_AUDIO_SINK@ ''${2-100}%
  '';

  sound-up = pkgs.writeShellScriptBin "sound-up" ''
    ${sound-change}/bin/sound-change up ${increments}
  '';

  # sound-set = pkgs.writeShellScriptBin "sound-set" ''
  #   ${sound-change}/bin/sound-change  set ''${1-100}
  # '';

  sound-down = pkgs.writeShellScriptBin "sound-down" ''
    ${sound-change}/bin/sound-change down ${increments}
  '';

  sound-toggle = pkgs.writeShellScriptBin "sound-toggle" ''
    ${sound-change}/bin/sound-change mute
  '';
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
    ];
    source = [
      "~/.config/hypr/extra.conf"
    ];

    # ################# Audio & Brightness ###################
    # ", xf86audioraisevolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
    # ", xf86audiolowervolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    # ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    #
    # ", XF86AudioPlay, exec, playerctl play-pause"
    # ", XF86AudioPause, exec, playerctl play-pause"
    # ", XF86AudioNext, exec, playerctl next"
    # ", XF86AudioPrev, exec, playerctl previous"
    #
    # # Keyboard backlight
    # ", keyboard_brightness_up_shortcut, exec, brightnessctl -d *::kbd_backlight set +33%"
    # ", keyboard_brightness_down_shortcut, exec, brightnessctl -d *::kbd_backlight set 33%-"
    #
    # # Screen brightness
    # ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
    # ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"

    bindl = [
      ",XF86AudioMute, exec, ${sound-toggle}/bin/sound-toggle" # Toggle Mute
      ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause" # Play/Pause Song
      ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next" # Next Song
      ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous" # Previous Song
      # ",switch:Lid Switch, exec, ${pkgs.hyprlock}/bin/hyprlock" # Lock when closing Lid
      ",XF86MonBrightnessUp, exec,   ${pkgs.brightnessctl}/bin/brightnessctl set +10%" # Brightness Up
      ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-" # Brightness Down
    ];

    bindle = [
      ",XF86AudioRaiseVolume, exec, ${sound-up}/bin/sound-up" # Sound Up
      ",XF86AudioLowerVolume, exec, ${sound-down}/bin/sound-down" # Sound Down
      ", keyboard_brightness_up_shortcut, exec, brightnessctl -d *::kbd_backlight set +33%"
      ", keyboard_brightness_down_shortcut, exec, brightnessctl -d *::kbd_backlight set 33%-"
    ];
    bind = let
      workspaces = [
        "0"
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "F1"
        "F2"
        "F3"
        "F4"
        "F5"
        "F6"
        "F7"
        "F8"
        "F9"
        "F10"
        "F11"
        "F12"
      ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l";
        right = "r";
        up = "u";
        down = "d";
        h = left;
        l = right;
        k = up;
        j = down;
      };

      mainMod = "SUPER";
      menu = "${pkgs.killall}/bin/killall wofi || wofi --show drun --allow-images";
      # browser = google-chrome-stable
      # browser = "${config.programs.go.package}/bin/swaylock";
      # $fileManager = dolphin
      # $menu = wofi --show drun
      # hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
      #swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      #playerctl = "${config.services.playerctld.package}/bin/playerctl";
      #playerctld = "${config.services.playerctld.package}/bin/playerctld";
      #makoctl = "${config.services.mako.package}/bin/makoctl";
      #wofi = "${config.programs.wofi.package}/bin/wofi";
      #pass = config.programs.password-store.package;
      #}}/bin/pass-wofi";
      #grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
      #pactl = "${pkgs.pulseaudio}/bin/pactl";
      #tly = "${pkgs.tly}/bin/tly";
      #gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
      #notify-send = "${pkgs.libnotify}/bin/notify-send";
      #gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
      #rdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
      #defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";
      #terminal = config.home.sessionVariables.TERM;
      #browser = defaultApp "x-scheme-handler/https";
      #editor = defaultApp "text/plain";
    in
      [
        # Screen shot # https://wiki.hyprland.org/FAQ/#how-do-i-screenshot
        ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "SHIFTCTRL, P, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        #TODO: referece the audio-select bin
        "$hyper, A, exec, audio-select"
        "$hyper, P, exec, wofi-pass"
        "$hyper, E, exec, wofi-emoji fill"

        #################### Clipboard Manager ####################
        "SUPER, V, exec, clipboard-menu"
        "SUPERSHIFT, V, exec, clipboard-clear"
        "SUPERALT, V, exec, clipboard-delete"

        #################### Computer Mange ####################

        "SUPERSHIFT,e,exit"

        #################### Program Launch ####################
        # "$browser = google-chrome-stable"
        # "$terminal = kitty"
        # "$fileManager = dolphin"
        # "$menu = wofi --show drun"
        "${mainMod}, B, exec, $browser"
        "${mainMod}, T, exec, $terminal -e 't'" # start tmux sesh
        "${mainMod}SHIFT, T, exec, $terminal"
        "${mainMod}, Q, killactive,"
        "${mainMod}, R, exec, ${menu}"
        "${mainMod}, E, exec, $fileManager"

        #################### Basic Bindings ####################
        # ",q,killactive"
        "$mainMod, Escape, exec, wlogout -p layer-shell"

        "SUPER,s,togglesplit"
        "SUPER,f,fullscreen,1"
        "SUPER,m,fullscreen,1"
        "SUPERSHIFT,f,fullscreen,0"
        "SUPERSHIFT,space,togglefloating"
        "${mainMod},G,togglefloating"
        "SUPERSHIFT,q ,exit"

        "SUPER,minus,splitratio,-0.25"
        "SUPERSHIFT,minus,splitratio,-0.3333333"

        "SUPER,equal,splitratio,0.25"
        "SUPERSHIFT,equal,splitratio,0.3333333"

        # "SUPER,g,togglegroup"
        # "SUPER,t,lockactivegroup,toggle"
        "SUPER,apostrophe,changegroupactive,f"
        "SUPERSHIFT,apostrophe,changegroupactive,b"

        "SUPER,u,togglespecialworkspace"
        "SUPERSHIFT,u,movetoworkspacesilent,special"
        # "$mainMod, G, togglefloating"
        #Move workspaces like popos
        "SUPERSHIFT, K, workspace, e+1"
        "SUPERSHIFT, J, workspace, e-1"
      ]
      ++
      # Change workspace
      (map
        (
          n: "$mainMod,${n},workspace,name:${n}"
        )
        workspaces)
      ++
      # Move window to workspace
      (map
        (
          n: "SHIFTALT,${n},movetoworkspace,name:${n}"
        )
        workspaces)
      ++
      # Move focus
      (lib.mapAttrsToList
        (
          key: direction: "$mainMod,${key},movefocus,${direction}"
        )
        directions)
      ++
      # Swap windows
      (lib.mapAttrsToList
        (
          key: direction: "SUPERSHIFT,${key},swapwindow,${direction}"
        )
        directions)
      ++
      # Move windows
      (lib.mapAttrsToList
        (
          key: direction: "SHIFTALT,${key},movewindoworgroup,${direction}"
        )
        directions)
      ++
      # Move monitor focus
      (lib.mapAttrsToList
        (
          key: direction: "SUPERALT,${key},focusmonitor,${direction}"
        )
        directions)
      ++
      # Move workspace to other monitor
      (lib.mapAttrsToList
        (
          key: direction: "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        )
        directions);
  };
}
