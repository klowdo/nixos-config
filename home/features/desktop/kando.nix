{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.kando;
in {
  options.features.desktop.kando.enable =
    mkEnableOption "Kando pie menu with Hyprland integration";

  config = mkIf cfg.enable {
    home.packages = [pkgs.kando];

    xdg.configFile."kando/menus.json".text = builtins.toJSON {
      menus = [
        {
          shortcut = "Control+Space";
          shortcutID = "example-menu";
          centered = false;
          root = {
            type = "submenu";
            name = "Example Menu";
            icon = "award_star";
            iconTheme = "material-symbols-rounded";
            children = [
              {
                type = "submenu";
                name = "Apps";
                icon = "apps";
                iconTheme = "material-symbols-rounded";
                children = [
                  {
                    type = "command";
                    data.command = "x-www-browser";
                    name = "Web Browser";
                    icon = "globe";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-email";
                    name = "E-Mail";
                    icon = "mail";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "gimp";
                    name = "GIMP";
                    icon = "gimp";
                    iconTheme = "simple-icons";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open ~";
                    name = "File Browser";
                    icon = "folder_shared";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "x-terminal-emulator";
                    name = "Terminal";
                    icon = "terminal";
                    iconTheme = "material-symbols-rounded";
                  }
                ];
              }
              {
                type = "submenu";
                name = "Web Links";
                icon = "public";
                iconTheme = "material-symbols-rounded";
                children = [
                  {
                    type = "uri";
                    data.uri = "https://www.google.com";
                    name = "Google";
                    icon = "google";
                    iconTheme = "simple-icons";
                  }
                  {
                    type = "uri";
                    data.uri = "https://github.com/kando-menu/kando";
                    name = "Kando on GitHub";
                    icon = "github";
                    iconTheme = "simple-icons";
                  }
                  {
                    type = "uri";
                    data.uri = "https://ko-fi.com/schneegans";
                    name = "Kando on Ko-fi";
                    icon = "kofi";
                    iconTheme = "simple-icons";
                  }
                  {
                    type = "uri";
                    data.uri = "https://www.youtube.com/@simonschneegans";
                    name = "Kando on YouTube";
                    icon = "youtube";
                    iconTheme = "simple-icons";
                  }
                  {
                    type = "uri";
                    data.uri = "https://discord.gg/hZwbVSDkhy";
                    name = "Kando on Discord";
                    icon = "discord";
                    iconTheme = "simple-icons";
                  }
                ];
              }
              {
                type = "hotkey";
                data = {
                  hotkey = "ControlLeft+AltLeft+ArrowRight";
                  delayed = false;
                };
                name = "Next Workspace";
                icon = "arrow_forward";
                iconTheme = "material-symbols-rounded";
              }
              {
                type = "submenu";
                name = "Clipboard";
                icon = "assignment";
                iconTheme = "material-symbols-rounded";
                children = [
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "ControlLeft+KeyV";
                      delayed = true;
                    };
                    name = "Paste";
                    icon = "content_paste_go";
                    iconTheme = "material-symbols-rounded";
                    angle = 90;
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "ControlLeft+KeyC";
                      delayed = true;
                    };
                    name = "Copy";
                    icon = "content_copy";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "ControlLeft+KeyX";
                      delayed = true;
                    };
                    name = "Cut";
                    icon = "cut";
                    iconTheme = "material-symbols-rounded";
                  }
                ];
              }
              {
                type = "submenu";
                name = "Audio";
                icon = "play_circle";
                iconTheme = "material-symbols-rounded";
                children = [
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "MediaTrackNext";
                      delayed = false;
                    };
                    name = "Next Track";
                    icon = "skip_next";
                    iconTheme = "material-symbols-rounded";
                    angle = 90;
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "MediaPlayPause";
                      delayed = false;
                    };
                    name = "Play / Pause";
                    icon = "play_pause";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "AudioVolumeMute";
                      delayed = false;
                    };
                    name = "Mute";
                    icon = "music_off";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "MediaTrackPrevious";
                      delayed = false;
                    };
                    name = "Previous Track";
                    icon = "skip_previous";
                    iconTheme = "material-symbols-rounded";
                    angle = 270;
                  }
                ];
              }
              {
                type = "submenu";
                name = "Windows";
                icon = "select_window";
                iconTheme = "material-symbols-rounded";
                children = [
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "MetaLeft+ArrowUp";
                      delayed = true;
                    };
                    name = "Toggle Maximize";
                    icon = "open_in_full";
                    iconTheme = "material-symbols-rounded";
                    angle = 0;
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "MetaLeft+ArrowRight";
                      delayed = true;
                    };
                    name = "Tile Right";
                    icon = "text_select_jump_to_end";
                    iconTheme = "material-symbols-rounded";
                    angle = 90;
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "AltLeft+F4";
                      delayed = true;
                    };
                    name = "Close Window";
                    icon = "cancel_presentation";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "hotkey";
                    data = {
                      hotkey = "MetaLeft+ArrowLeft";
                      delayed = true;
                    };
                    name = "Tile Left";
                    icon = "text_select_jump_to_beginning";
                    iconTheme = "material-symbols-rounded";
                    angle = 270;
                  }
                ];
              }
              {
                type = "hotkey";
                data = {
                  hotkey = "ControlLeft+AltLeft+ArrowLeft";
                  delayed = false;
                };
                name = "Previous Workspace";
                icon = "arrow_back";
                iconTheme = "material-symbols-rounded";
              }
              {
                type = "submenu";
                name = "Bookmarks";
                icon = "folder_special";
                iconTheme = "material-symbols-rounded";
                children = [
                  {
                    type = "command";
                    data.command = "xdg-open \"$(xdg-user-dir DOWNLOAD)\"";
                    name = "Downloads";
                    icon = "download";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open \"$(xdg-user-dir VIDEOS)\"";
                    name = "Videos";
                    icon = "video_camera_front";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open \"$(xdg-user-dir PICTURES)\"";
                    name = "Pictures";
                    icon = "imagesmode";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open \"$(xdg-user-dir DOCUMENTS)\"";
                    name = "Documents";
                    icon = "text_ad";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open \"$(xdg-user-dir DESKTOP)\"";
                    name = "Desktop";
                    icon = "desktop_windows";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open ~";
                    name = "Home";
                    icon = "home";
                    iconTheme = "material-symbols-rounded";
                  }
                  {
                    type = "command";
                    data.command = "xdg-open \"$(xdg-user-dir MUSIC)\"";
                    name = "Music";
                    icon = "music_note";
                    iconTheme = "material-symbols-rounded";
                  }
                ];
              }
            ];
          };
        }
      ];
      collections = [
        {
          name = "Favorites";
          icon = "favorite";
          iconTheme = "material-symbols-rounded";
          tags = ["favs"];
        }
        {
          name = "New Collection";
          icon = "sell";
          iconTheme = "material-symbols-rounded";
          tags = [];
        }
        {
          name = "New Collection";
          icon = "sell";
          iconTheme = "material-symbols-rounded";
          tags = [];
        }
      ];
    };

    xdg.configFile."kando/config.json".text = builtins.toJSON {
      trayIconFlavor = "none";
      ignoreWriteProtectedConfigFiles = true;
      menuTheme = "default";
      darkMenuTheme = "default";
      menuThemeColors = {};
      darkMenuThemeColors = {};
      enableDarkModeForMenuThemes = false;
      soundTheme = "none";
      soundVolume = 0.5;
      settingsWindowColorScheme = "system";
      settingsWindowFlavor = "transparent-system";
      lazyInitialization = false;
      enableVersionCheck = false;
      zoomFactor = 1;
      centerDeadZone = 50;
      minParentDistance = 150;
      dragThreshold = 15;
      fadeInDuration = 150;
      fadeOutDuration = 200;
      enableMarkingMode = true;
      enableTurboMode = true;
      warpMouse = true;
      enableGamepad = false;
      sameShortcutBehavior = "nothing";
      hideSettingsButton = false;
      settingsButtonPosition = "bottom-right";
    };

    features.desktop.solaar = {
      enable = true;
      rules = [
        [
          {Key = ["Mouse Gesture Button" "pressed"];}
          {KeyPress = ["Control_L" "space"];}
        ]
      ];
    };

    wayland.windowManager.hyprland.settings = {
      exec-once = ["kando --in-process-gpu"];

      windowrule = [
        "match:class (kando), no_blur on"
        "match:class (kando), opaque on"
        "match:class (kando), size (monitor_w*1.0) (monitor_h*1.0)"
        "match:class (kando), border_size 0"
        "match:class (kando), no_anim on"
        "match:class (kando), float on"
        "match:class (kando), pin on"
      ];

      bind = [
        "CTRL, Space, global, org.chromium.Chromium:example-menu"
      ];
    };
  };
}
