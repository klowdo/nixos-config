{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  imports = [
    ./hypr
    ./wlogout.nix
    ## To use the absolute latest
    # inputs.hyprland.homeManagerModules.default
  ];

  config = mkIf cfg.enable {
    services.way-displays = {
      enable = true;
      logThreshold = "WARNING";
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      T_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mainMod" = "SUPER";
        "$editor" = "nvim";
        "$terminal" = "kitty";
        "$browser" = "${config.programs.firefox.package}/bin/firefox";
        "$menu" = "wofi --show drun --allow-images";
        "$fileManager" = "thunar";
        "$hyper" = "CONTROL_SHIFT_ALT_SUPER";

        xwayland = {
          force_zero_scaling = true;
        };

        exec-once = [
          "waybar"
          "hyprpaper"
          "hypridle"
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        ];

        env = [
          "XCURSOR_SIZE,32"
          "WLR_NO_HARDWARE_CURSORS,1"
          "AQ_DRM_DEVICES,/dev/dri/card1"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
        ];

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 1;
          # "col.active_border" = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
          # "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        decoration = {
          # "col.shadow" = "rgba(1E202966)";
          shadow = {
            enabled = false;
            range = 60;
            offset = "1 2";
            render_power = 3;
            scale = 0.97;
          };
          rounding = 3;
          blur = {
            enabled = false;
            size = 3;
            passes = 3;
          };
          active_opacity = 1.0;
          inactive_opacity = 0.7;
        };

        animations = {
          enabled = false;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          vfr = true;
        };

        master = {};

        gestures = {
          workspace_swipe = false;
        };

        # trigger when the switch is turning off
        windowrule = [
          "float, file_progress"
          "float, confirm"
          "float, dialog"
          "float, download"
          "float, notification"
          "float, error"
          "float, splash"
          "float, confirmreset"
          "float, title:Open File"
          "float, title:branchdialog"
          "float, Lxappearance"
          "float, Wofi"
          "float, dunst"
          "animation none,Wofi"
          "float,viewnior"
          "float,feh"
          "float, pavucontrol-qt"
          "float, pavucontrol"
          "float, file-roller"
          "fullscreen, wlogout"
          "float, title:wlogout"
          "fullscreen, title:wlogout"
          "idleinhibit focus, mpv"
          "idleinhibit fullscreen, firefox"
          "float, title:^(Media viewer)$"
          "float, title:^(Volume Control)$"
          "float, title:^(Picture-in-Picture)$"
          "size 800 600, title:^(Volume Control)$"
          "move 75 44%, title:^(Volume Control)$"
        ];

        # bind = [
        #   ################# Audio & Brightness ###################
        #   ", xf86audioraisevolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        #   ", xf86audiolowervolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        #   ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        #
        #   ", XF86AudioPlay, exec, playerctl play-pause"
        #   ", XF86AudioPause, exec, playerctl play-pause"
        #   ", XF86AudioNext, exec, playerctl next"
        #   ", XF86AudioPrev, exec, playerctl previous"
        #
        #   # Keyboard backlight
        #   ", keyboard_brightness_up_shortcut, exec, brightnessctl -d *::kbd_backlight set +33%"
        #   ", keyboard_brightness_down_shortcut, exec, brightnessctl -d *::kbd_backlight set 33%-"
        #
        #   # Screen brightness
        #   ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        #   ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        #
        #   # Screen shot # https://wiki.hyprland.org/FAQ/#how-do-i-screenshot
        #   ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        #   #################### Basic Bindings ####################
        #   "$mainMod, return, exec, kitty -e zellij-ps"
        #   "$mainMod, t, exec, kitty -e zsh -c 'neofetch; exec zsh'"
        #   "$mainMod SHIFT, e, exec, kitty -e zellij_nvim"
        #   "$mainMod, o, exec, thunar"
        #   "$mainMod, Escape, exec, wlogout -p layer-shell"
        #   "$mainMod, Space, togglefloating"
        #   "$mainMod, q, killactive"
        #   "$mainMod, M, fullscreen"
        #   "$mainMod, F, fullscreen"
        #   "$mainMod, V, togglefloating"
        #   "$mainMod, D, exec, wofi --show drun --allow-images"
        #   "$mainMod SHIFT, S, exec, bemoji"
        #   "$mainMod, P, exec, wofi-pass"
        #   "$mainMod SHIFT, P, pseudo"
        #   "$mainMod, J, togglesplit"
        #   "$mainMod, left, movefocus, l"
        #   "$mainMod, right, movefocus, r"
        #   "$mainMod, up, movefocus, u"
        #   "$mainMod, down, movefocus, d"
        #   "$mainMod, 1, workspace, 1"
        #   "$mainMod, 2, workspace, 2"
        #   "$mainMod, 3, workspace, 3"
        #   "$mainMod, 4, workspace, 4"
        #   "$mainMod, 5, workspace, 5"
        #   "$mainMod, 6, workspace, 6"
        #   "$mainMod, 7, workspace, 7"
        #   "$mainMod, 8, workspace, 8"
        #   "$mainMod, 9, workspace, 9"
        #   "$mainMod, 0, workspace, 10"
        #   "$mainMod SHIFT, 1, movetoworkspace, 1"
        #   "$mainMod SHIFT, 2, movetoworkspace, 2"
        #   "$mainMod SHIFT, 3, movetoworkspace, 3"
        #   "$mainMod SHIFT, 4, movetoworkspace, 4"
        #   "$mainMod SHIFT, 5, movetoworkspace, 5"
        #   "$mainMod SHIFT, 6, movetoworkspace, 6"
        #   "$mainMod SHIFT, 7, movetoworkspace, 7"
        #   "$mainMod SHIFT, 8, movetoworkspace, 8"
        #   "$mainMod SHIFT, 9, movetoworkspace, 9"
        #   "$mainMod SHIFT, 0, movetoworkspace, 10"
        #   "$mainMod, mouse_down, workspace, e+1"
        #   "$mainMod, mouse_up, workspace, e-1"
        # ];

        windowrulev2 = [
          "workspace 1,class:(Emacs)"
          "workspace 2,class:(jetbrains-rider)"
          "workspace 3,opacity 1.0, class:(brave-browser)"
          "workspace 3,opacity 1.0, class:(firefox)"
          "workspace 4,class:(spotify)"
          "workspace 4,class:(com.obsproject.Studio)"
          "workspace 5,class:(Slack)"
          "animation none, class:(jetbrains-rider)"
          "animation none, initialClass:(jetbrains-rider)"
          "opaque, class:(jetbrains-rider)"
          "opaque, initialTitle:(Huddle),initialClass:(Slack)"
        ];
      };
    };
  };
}
