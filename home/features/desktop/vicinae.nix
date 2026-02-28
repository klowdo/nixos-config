{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.vicinae;

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

      setupExtensionPreferences = true;

      extensionSettings = [
        {
          id = "extension.homeassistant";
          attributes = {
            camerarefreshinterval = "3000";
            ignorecerts = false;
            instance = "https://assistant.home.flixen.se";
            preferredapp = "browser";
            showEntityId = false;
            token = "@TOKEN@";
            usePing = true;
          };
          secrets."@TOKEN@" = config.sops.secrets."applications/homeassistant/token".path;
        }
        {
          id = "extension.hypr-keybinds";
          attributes.keybindsConfigPath = "${config.xdg.configHome}/hypr/hyprland.conf";
        }
      ];

      extensions = [
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
        (config.lib.vicinae.mkRayCastExtension {
          name = "homeassistant";
          rev = "cc18ab11d5144dc02ae56ad43e42b3ed889bcce6";
          sha256 = "sha256-WwWiptPBQHRg/xJP63UWiRxARHWd/XiSoe+ew1cfZqY=";
        })
      ];

      settings = {
        faviconService = "twenty";
        font.size = 10;
        poptorootonclose = false;
        rootsearch.searchfiles = false;
        window = {
          csd = true;
          rounding = 10;
        };
      };
    };

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

      Install.WantedBy = ["graphical-session.target"];
    };

    wayland.windowManager.hyprland.settings = mkIf cfg.enableHyprlandSupport {
      layerrule = [
        "blur,vicinae"
        "ignorealpha 0,vicinae"
        "noanim,vicinae"
      ];

      misc.focus_on_activate = true;
    };
  };
}
