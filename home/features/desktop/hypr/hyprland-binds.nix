{
  lib,
  config,
  pkgs,
  ...
}: let
  caelestiaEnabled = config.features.desktop.bar.caelestia.enable or false;
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

  lockCmd =
    if caelestiaEnabled
    then "caelestia shell lock lock"
    else "${pkgs.hyprlock}/bin/hyprlock";

  lock-screen = pkgs.writeShellScriptBin "lock-screen" ''
    exec ${lockCmd}
  '';

  unlock-lockscreen = pkgs.writeShellScriptBin "unlock-lockscreen" ''
    ${pkgs.hyprland}/bin/hyprctl --instance 0 dispatch exec "${lock-screen}/bin/lock-screen"
  '';

  lid-close = pkgs.writeShellScriptBin "lid-close" ''
    monitor_count=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq 'length')
    if [ "$monitor_count" -le 1 ]; then
      ${lock-screen}/bin/lock-screen & sleep 0.5 && ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
    fi
  '';
in {
  home.packages = with pkgs; [
    wl-mirror
    wl-clipboard
    grim
    slurp
    satty
    lock-screen
    unlock-lockscreen
  ];
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
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

    bindl =
      [
        ",XF86AudioMute, exec, ${sound-toggle}/bin/sound-toggle"
        ",switch:on:Lid Switch, exec, ${lid-close}/bin/lid-close"
        ",switch:off:Lid Switch, exec, hyprctl dispatch dpms on"
      ]
      ++ lib.optionals (!caelestiaEnabled) [
        ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10%"
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
      ];

    bindle = [
      ",XF86AudioRaiseVolume, exec, ${sound-up}/bin/sound-up"
      ",XF86AudioLowerVolume, exec, ${sound-down}/bin/sound-down"
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
      hyper = "CONTROL_SHIFT_ALT_SUPER";
      browser = config.features.defaults.browser.command;
      terminal = config.features.defaults.terminal.command;
      menu = config.features.defaults.launcher.command;
      fileManager = config.features.defaults.fileManager.command;
      sessionMenu = config.features.defaults.sessionMenu.command;
    in
      [
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFTCTRL, P, exec, grim -g \"$(slurp)\" - | satty -f -"
        "${hyper}, P, exec, grim -g \"$(slurp)\" - | satty -f -"
        "${hyper}, A, exec, audio-select"
        "${hyper}, B, exec, wofi-bitwarden"
        "${hyper}, E, exec, wofi-emoji fill"
        "${hyper}, T, exec, darkman toggle"

        "SUPER, V, exec, clipboard-menu"
        "SUPERSHIFT, V, exec, clipboard-clear"
        "SUPERALT, V, exec, clipboard-delete"

        "CTRL SHIFT, space, pass, class:^(Slack)$"

        "SUPERSHIFT,e,exit"

        "${mainMod}, B, exec, ${browser}"
        "${mainMod}, T, exec, ${terminal} -e 't'"
        "${mainMod}SHIFT, T, exec, ${terminal}"
        "${mainMod}, Q, killactive,"
        "${mainMod}, R, exec, ${menu}"
        "${mainMod}, E, exec, ${fileManager}"

        "${mainMod}, Escape, exec, ${sessionMenu}"

        "SUPER,s,layoutmsg,togglesplit"
        "SUPER,f,fullscreen,1"
        "SUPER,m,fullscreen,1"
        "SUPERSHIFT,f,fullscreen,0"
        "SUPERSHIFT,space,togglefloating"
        "${mainMod},G,togglefloating"
        "SUPERSHIFT,q ,exit"

        "SUPER,minus,layoutmsg,splitratio -0.25"
        "SUPERSHIFT,minus,layoutmsg,splitratio -0.3333333"

        "SUPER,equal,layoutmsg,splitratio 0.25"
        "SUPERSHIFT,equal,layoutmsg,splitratio 0.3333333"

        "SUPER,apostrophe,changegroupactive,f"
        "SUPERSHIFT,apostrophe,changegroupactive,b"

        "SUPER,u,togglespecialworkspace"
        "SUPERSHIFT,u,movetoworkspacesilent,special"
        "SUPERSHIFT, K, workspace, e+1"
        "SUPERSHIFT, J, workspace, e-1"
      ]
      ++ (map
        (
          n: "${mainMod},${n},workspace,${n}"
        )
        workspaces)
      ++ (map
        (
          n: "SHIFTALT,${n},movetoworkspace,${n}"
        )
        workspaces)
      ++ (lib.mapAttrsToList
        (
          key: direction: "${mainMod},${key},movefocus,${direction}"
        )
        directions)
      ++ (lib.mapAttrsToList
        (
          key: direction: "SUPERSHIFT,${key},swapwindow,${direction}"
        )
        directions)
      ++ (lib.mapAttrsToList
        (
          key: direction: "SHIFTALT,${key},movewindoworgroup,${direction}"
        )
        directions)
      ++ (lib.mapAttrsToList
        (
          key: direction: "SUPERALT,${key},focusmonitor,${direction}"
        )
        directions)
      ++ (lib.mapAttrsToList
        (
          key: direction: "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        )
        directions);
  };
}
