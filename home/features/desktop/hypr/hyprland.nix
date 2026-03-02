{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
  caelestiaEnabled = config.features.desktop.bar.caelestia.enable or false;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  imports = [
    ../wlogout.nix
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pyprland
      hyprpicker
      hyprcursor
      hypridle
      hyprpaper
      swappy
      hyprland-protocols
    ];
    services.custom-way-displays = {
      enable = false; # Disabled in favor of hyprdynamicmonitors
      logThreshold = "WARNING";
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      T_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    };
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mainMod" = "SUPER";
        "$editor" = config.features.defaults.editor.command;
        "$terminal" = config.features.defaults.terminal.command;
        "$browser" = config.features.defaults.browser.command;
        "$menu" = config.features.defaults.launcher.command;
        "$fileManager" = config.features.defaults.fileManager.command;
        "$sessionMenu" = config.features.defaults.sessionMenu.command;
        "$hyper" = "CONTROL_SHIFT_ALT_SUPER";

        source = [
          "~/.config/hypr/config.d/*.conf"
        ];

        xwayland = {
          force_zero_scaling = true;
        };

        exec-once =
          [
            "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
            "/run/wrappers/bin/gnome-keyring-daemon --start"
          ]
          ++ lib.optionals (!caelestiaEnabled) [
            "hypridle"
          ];

        env = [
          "XCURSOR_SIZE,32"
          "WLR_NO_HARDWARE_CURSORS,1"
          "AQ_DRM_DEVICES,/dev/dri/card1"
        ];

        # cursor = {
        #   no_hardware_cursors = true;
        #   default_monitor = "";
        # };

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

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          vfr = true;
        };

        master = {};

        gesture = [
          "3, horizontal, workspace"
        ];

        # Define persistent workspaces to ensure proper ordering
        workspace = [
          "1, persistent:true"
          "2, persistent:true"
          "3, persistent:true"
          "4, persistent:true"
          "5, persistent:true"
          "6, persistent:false"
          "7, persistent:false"
          "8, persistent:false"
          "9, persistent:false"
          "0, persistent:false"
        ];

        windowrule = [
          "match:class file_progress, float on"
          "match:class confirm, float on"
          "match:class dialog, float on"
          "match:class download, float on"
          "match:class notification, float on"
          "match:class error, float on"
          "match:class splash, float on"
          "match:class confirmreset, float on"
          "match:title Open File, float on"
          "match:title branchdialog, float on"
          "match:class Lxappearance, float on"
          "match:class Wofi, float on"
          "match:class dunst, float on"
          "match:class Wofi, no_anim on"
          "match:class viewnior, float on"
          "match:class feh, float on"
          "match:class pavucontrol-qt, float on"
          "match:class pavucontrol, float on"
          "match:class file-roller, float on"
          "match:class wlogout, fullscreen on"
          "match:title wlogout, float on"
          "match:title wlogout, fullscreen on"
          "match:class mpv, idle_inhibit focus"
          "match:class firefox, idle_inhibit fullscreen"
          "match:title ^(Media viewer)$, float on"
          "match:title ^(Volume Control)$, float on"
          "match:title ^(Picture-in-Picture)$, float on"
          "match:title ^(Volume Control)$, size 800 600"
          "match:title ^(Volume Control)$, move 75 (monitor_h*0.44)"
          "match:class (Emacs), workspace 1"
          "match:class (jetbrains-rider), workspace 2"
          "match:class (brave-browser), workspace 3, opacity 1.0"
          "match:class (firefox), workspace 3, opacity 1.0"
          "match:class (spotify), workspace 4"
          "match:class (Deezer), workspace 4"
          "match:class (com.obsproject.Studio), workspace 4"
          "match:class (Slack), workspace 5"
          "match:class (Slack), tile on"
          "match:class (kitty), animation slide top"
          "match:title .*Bitwarden Password Manager.*, float on"
          "match:title .*Bitwarden Password Manager.*, size 1266 687"
          "match:class (jetbrains-rider), no_anim on"
          "match:initial_class (jetbrains-rider), no_anim on"
          "match:class (jetbrains-rider), opaque on"
          "match:title ^Huddle:.*, match:class (Slack), opaque on"
          "match:title ^Huddle:.*, match:class (Slack), no_blur on"
          "match:title .*(YouTube|youtube).*, match:class (firefox), opaque on"
        ];
      };
    };
  };
}
