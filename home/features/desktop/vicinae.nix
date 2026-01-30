{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.vicinae;

  # Vicinae extensions repository
  vicinaeExtensions = pkgs.fetchFromGitHub {
    owner = "vicinaehq";
    repo = "extensions";
    rev = "b698ce7ecb58dec1efe297f87370253d8f6ba9d5";
    sha256 = "sha256-jhlWZ6WfFBjS7CXbUOreZ2zEnYiVYfeqKOaZguFFslA=";
  };
in {
  options.features.desktop.vicinae = {
    enable = mkEnableOption "enable vicinae launcer";
    enableHyprlandSupport = mkEnableOption "enable Hyprland integration with keybindings and window rules";
  };

  config = mkIf cfg.enable {
    programs.vicinae = {
      enable = true;

      # Extensions
      extensions = [
        # Vicinae native extensions
        (config.lib.vicinae.mkExtension {
          name = "hypr-keybinds";
          src = vicinaeExtensions + "/extensions/hypr-keybinds";
        })
        (config.lib.vicinae.mkExtension {
          name = "bluetooth";
          src = vicinaeExtensions + "/extensions/bluetooth";
        })
        (config.lib.vicinae.mkExtension {
          name = "wifi-commander";
          src = vicinaeExtensions + "/extensions/wifi-commander";
        })
        (config.lib.vicinae.mkExtension {
          name = "nix";
          src = vicinaeExtensions + "/extensions/nix";
        })
        (config.lib.vicinae.mkExtension {
          name = "firefox";
          src = vicinaeExtensions + "/extensions/firefox";
        })
        # NOTE: systemd extension removed due to node-gyp compatibility issues with Node.js 22
        # Error: TypeError: Cannot assign to read only property 'cflags'
        # (config.lib.vicinae.mkExtension {
        #   name = "systemd";
        #   src = vicinaeExtensions + "/extensions/systemd";
        # })

        # Raycast extension - Home Assistant
        (config.lib.vicinae.mkRayCastExtension {
          name = "homeassistant";
          rev = "cc18ab11d5144dc02ae56ad43e42b3ed889bcce6";
          sha256 = "sha256-WwWiptPBQHRg/xJP63UWiRxARHWd/XiSoe+ew1cfZqY=";
        })
        # NOTE: gif-search removed - dependency download fails with 404
        # (config.lib.vicinae.mkRayCastExtension {
        #   name = "gif-search";
        #   sha256 = "sha256-G7il8T1L+P/2mXWJsb68n4BCbVKcrrtK8GnBNxzt73Q=";
        #   rev = "4d417c2dfd86a5b2bea202d4a7b48d8eb3dbaeb1";
        # })
      ];

      settings = {
        faviconService = "twenty";
        font = {
          size = 10;
        };
        poptorootonclose = false;
        rootsearch = {
          searchfiles = false;
        };
        window = {
          csd = true;
          # opacity = 0.95;
          rounding = 10;
        };
      };
    };

    # custom systemd service with proper path
    systemd.user.services.vicinae-server = {
      Unit = {
        Description = "Vicinae Launcher Server";
        Documentation = "https://docs.vicinae.com";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        Requires = ["dbus.socket"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${config.programs.vicinae.package}/bin/vicinae server --replace";
        Restart = "on-failure";
        RestartSec = 10;
        KillMode = "process";
        Environment = [
          "NIXOS_OZONE_WL=1"
          "ELECTRON_OZONE_PLATFORM_HINT=wayland"
          "MOZ_ENABLE_WAYLAND=1"
          "XDG_CURRENT_DESKTOP=Hyprland"
          "XDG_SESSION_TYPE=wayland"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Hyprland integration
    wayland.windowManager.hyprland.settings = mkIf cfg.enableHyprlandSupport {
      # Keybindings
      # bind = [
      #   # Toggle vicinae launcher (using Space since R is already used for menu)
      #   "SUPER, Space, exec, ${config.programs.vicinae.package}/bin/vicinae toggle"
      #   # Clipboard history
      #   "SUPER, C, exec, ${config.programs.vicinae.package}/bin/vicinae vicinae://extensions/vicinae/clipboard/history"
      # ];

      # Window rules for optimal appearance
      layerrule = [
        "blur,vicinae"
        "ignorealpha 0,vicinae"
        "noanim,vicinae"
      ];

      # Auto-focus windows after vicinae triggers actions
      misc = {
        focus_on_activate = true;
      };
    };
  };
}
