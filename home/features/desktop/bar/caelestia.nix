{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.bar.caelestia;
  stylixFont = config.stylix.fonts.monospace.name or "CaskaydiaCove Nerd Font";
  stylixSansFont = config.stylix.fonts.sansSerif.name or "Rubik";
  stylixWallpaper = config.stylix.image or null;

  stylixColors = with config.lib.stylix.colors; {
    primary_paletteKeyColor = base0D;
    secondary_paletteKeyColor = base04;
    tertiary_paletteKeyColor = base0E;
    neutral_paletteKeyColor = base04;
    neutral_variant_paletteKeyColor = base04;
    background = base00;
    onBackground = base05;
    surface = base00;
    surfaceDim = base00;
    surfaceBright = base02;
    surfaceContainerLowest = base00;
    surfaceContainerLow = base01;
    surfaceContainer = base01;
    surfaceContainerHigh = base02;
    surfaceContainerHighest = base03;
    onSurface = base05;
    surfaceVariant = base02;
    onSurfaceVariant = base04;
    inverseSurface = base05;
    inverseOnSurface = base01;
    outline = base04;
    outlineVariant = base02;
    shadow = base00;
    scrim = base00;
    surfaceTint = base0D;
    primary = base0D;
    onPrimary = base00;
    primaryContainer = base0D;
    onPrimaryContainer = base07;
    inversePrimary = base0D;
    secondary = base04;
    onSecondary = base01;
    secondaryContainer = base02;
    onSecondaryContainer = base04;
    tertiary = base0E;
    onTertiary = base00;
    tertiaryContainer = base0E;
    onTertiaryContainer = base00;
    error = base08;
    onError = base00;
    errorContainer = base08;
    onErrorContainer = base07;
    primaryFixed = base0D;
    primaryFixedDim = base0D;
    onPrimaryFixed = base00;
    onPrimaryFixedVariant = base01;
    secondaryFixed = base04;
    secondaryFixedDim = base04;
    onSecondaryFixed = base00;
    onSecondaryFixedVariant = base02;
    tertiaryFixed = base0E;
    tertiaryFixedDim = base0E;
    onTertiaryFixed = base00;
    onTertiaryFixedVariant = base01;
    term0 = base00;
    term1 = base08;
    term2 = base0B;
    term3 = base0A;
    term4 = base0D;
    term5 = base0E;
    term6 = base0C;
    term7 = base05;
    term8 = base03;
    term9 = base08;
    term10 = base0B;
    term11 = base0A;
    term12 = base0D;
    term13 = base0E;
    term14 = base0C;
    term15 = base07;
    rosewater = base06;
    flamingo = base0F;
    pink = base0E;
    mauve = base0E;
    red = base08;
    maroon = base08;
    peach = base09;
    yellow = base0A;
    green = base0B;
    teal = base0C;
    sky = base0C;
    sapphire = base0D;
    blue = base0D;
    lavender = base0E;
    text = base05;
    subtext1 = base04;
    subtext0 = base04;
    overlay2 = base03;
    overlay1 = base03;
    overlay0 = base02;
    surface2 = base02;
    surface1 = base01;
    surface0 = base01;
    base = base00;
    mantle = base00;
    crust = base00;
    success = base0B;
    onSuccess = base00;
    successContainer = base0B;
    onSuccessContainer = base07;
  };
in {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  options.features.desktop.bar.caelestia = {
    enable = mkEnableOption "Caelestia shell for Hyprland";

    package = mkOption {
      type = types.package;
      default = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
      description = "The caelestia-shell package to use";
    };

    useLauncher = mkOption {
      type = types.bool;
      default = false;
      description = "Use caelestia's built-in launcher instead of vicinae/wofi";
    };

    useLockScreen = mkOption {
      type = types.bool;
      default = true;
      description = "Use caelestia's lock screen instead of hyprlock";
    };

    useSessionMenu = mkOption {
      type = types.bool;
      default = true;
      description = "Use caelestia's session menu instead of wlogout";
    };

    useNotifications = mkOption {
      type = types.bool;
      default = true;
      description = "Use caelestia's notification system";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Caelestia shell configuration (shell.json)";
    };
  };

  config = mkIf cfg.enable {
    xdg.stateFile."caelestia/scheme-temp.json".text = builtins.toJSON {
      name = "stylix";
      flavour = "custom";
      mode = "dark";
      variant = "tonalspot";
      colours = stylixColors;
    };

    xdg.stateFile."caelestia/wallpaper/path-temp.txt" = mkIf (stylixWallpaper != null) {
      text = toString stylixWallpaper;
    };

    home.packages = with pkgs; [
      cava
      ddcutil
      brightnessctl
      lm_sensors
      libqalculate
      qalculate-gtk
      playerctl
      material-symbols
      nerd-fonts.caskaydia-cove
      rubik
      adwaita-icon-theme
    ];

    programs.caelestia = {
      enable = true;
      inherit (cfg) package;

      systemd = {
        enable = true;
        # target = "hyprland-session.target";
      };

      cli = {
        enable = true;
        settings = {
          enableHypr = true;
          enableGtk = true;
          enableQt = true;
          enableTerm = false;
          enableSpicetify = true;
          enableDiscord = false;
          enableBtop = true;
        };
      };

      settings = mkMerge [
        {
          appearance = {
            font = {
              family = {
                clock = stylixSansFont;
                material = "Material Symbols Rounded";
                mono = stylixFont;
                sans = stylixSansFont;
              };
            };
            transparency = {
              enabled = true;
              base = 0.9;
              layers = 0.5;
            };
          };

          bar = {
            entries = [
              {
                id = "logo";
                enabled = true;
              }
              {
                id = "workspaces";
                enabled = true;
              }
              {
                id = "activeWindow";
                enabled = true;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "tray";
                enabled = true;
              }
              {
                id = "clock";
                enabled = true;
              }
              {
                id = "statusIcons";
                enabled = true;
              }
              {
                id = "power";
                enabled = true;
              }
            ];
            status = {
              showAudio = true;
              showMicrophone = true;
              showKbLayout = true;
              showNetwork = true;
              showBluetooth = true;
              showBattery = true;
            };
          };

          services = {
            audio = {
              step = 5;
            };
            brightness = {
              step = 5;
            };
            gpuType = "NVIDIA"; # Uses fake nvidia-smi wrapper for Intel
            weather = {
              location = "Gothenburg";
              units = "metric";
            };
          };
          paths = {
            mediaGif = "root:/assets/bongocat.gif";
            # mediaGif =  ../../../../lib/duck.gif;
            sessionGif = ../../../../lib/duck.gif; #"root:/assets/kurukuru.gif";
            wallpaperDir = "~/Pictures/Wallpapers";
          };

          general = {
            apps = {
              terminal = [config.features.defaults.terminal.command or "kitty"];
              explorer = [config.features.defaults.fileManager.command or "nautilus"];
              audio = ["pavucontrol"];
            };
            battery = {
              warnLevels = [
                {
                  level = 20;
                  title = "Low battery";
                  message = "You might want to plug in a charger";
                  icon = "battery_android_frame_2";
                }
                {
                  level = 10;
                  title = "Did you see the previous message?";
                  message = "You should probably plug in a charger <b>now</b>";
                  icon = "battery_android_frame_1";
                }
                {
                  level = 5;
                  title = "Critical battery level";
                  message = "PLUG THE CHARGER RIGHT NOW!!";
                  icon = "battery_android_alert";
                  critical = true;
                }
              ];
              criticalLevel = 3;
            };
            idle = {
              lockBeforeSleep = true;
              inhibitWhenAudio = true;
              timeouts = [
                {
                  timeout = 180;
                  idleAction = "lock";
                }
                {
                  timeout = 300;
                  idleAction = "dpms off";
                  returnAction = "dpms on";
                }
                {
                  timeout = 600;
                  idleAction = ["systemctl" "suspend-then-hibernate"];
                }
              ];
            };
          };

          session = {
            enabled = true;
            vimKeybinds = true;
            commands = {
              lock = ["caelestia" "shell" "lock" "lock"];
              logout = ["loginctl" "terminate-user" ""];
              shutdown = ["systemctl" "poweroff"];
              reboot = ["systemctl" "reboot"];
              hibernate = ["systemctl" "hibernate"];
            };
          };

          utilities = {
            enabled = true;
            maxToasts = 4;
            toasts = {
              audioInputChanged = true;
              audioOutputChanged = true;
              capsLockChanged = true;
              chargingChanged = true;
              configLoaded = true;
              dndChanged = true;
              gameModeChanged = true;
              kbLayoutChanged = true;
              kbLimit = true;
              numLockChanged = true;
              vpnChanged = true;
              nowPlaying = false;
            };
            vpn = {
              enabled = true;
              provider = [
                {
                  name = "tailscale";
                  interface = "tailscale0";
                  displayName = "Tailscale";
                  enabled = true;
                }
              ];
            };
          };
        }
        cfg.settings
      ];
    };

    features.desktop.which-key.extraMenu = [
      {
        key = "d";
        desc = "Desktop";
        submenu = [
          {
            key = "l";
            desc = "Launcher";
            cmd = "caelestia shell drawers toggle launcher";
          }
          {
            key = "s";
            desc = "Session menu";
            cmd = "caelestia shell drawers toggle session";
          }
          {
            key = "p";
            desc = "Show panels";
            cmd = "caelestia shell drawers showall";
          }
          {
            key = "o";
            desc = "Control center";
            cmd = "caelestia shell controlCenter open";
          }
          {
            key = "n";
            desc = "Notifications";
            submenu = [
              {
                key = "c";
                desc = "Clear";
                cmd = "caelestia shell notifs clear";
              }
              {
                key = "d";
                desc = "Toggle DND";
                cmd = "caelestia shell notifs toggleDnd";
              }
            ];
          }
          {
            key = "m";
            desc = "Media";
            submenu = [
              {
                key = "p";
                desc = "Play/Pause";
                cmd = "caelestia shell mpris playPause";
              }
              {
                key = "n";
                desc = "Next";
                cmd = "caelestia shell mpris next";
              }
              {
                key = "b";
                desc = "Previous";
                cmd = "caelestia shell mpris previous";
              }
              {
                key = "s";
                desc = "Stop";
                cmd = "caelestia shell mpris stop";
              }
            ];
          }
          {
            key = "c";
            desc = "Color picker";
            submenu = [
              {
                key = "p";
                desc = "Pick";
                cmd = "caelestia shell picker open";
              }
              {
                key = "f";
                desc = "Pick (freeze)";
                cmd = "caelestia shell picker openFreeze";
              }
              {
                key = "c";
                desc = "Pick + copy";
                cmd = "caelestia shell picker openClip";
              }
              {
                key = "F";
                desc = "Freeze + copy";
                cmd = "caelestia shell picker openFreezeClip";
              }
            ];
          }
          {
            key = "g";
            desc = "Game mode toggle";
            cmd = "caelestia shell gameMode toggle";
          }
          {
            key = "i";
            desc = "Idle inhibitor toggle";
            cmd = "caelestia shell idleInhibitor toggle";
          }
        ];
      }
    ];

    wayland.windowManager.hyprland.settings = {
      "$menu" = mkIf cfg.useLauncher (mkForce "caelestia shell drawers toggle launcher");
      "$sessionMenu" = mkIf cfg.useSessionMenu (mkForce "caelestia shell drawers toggle session");

      "$kbSession" = "Ctrl+Alt, Delete";
      "$kbClearNotifs" = "Ctrl+Alt, C";
      "$kbShowPanels" = "Super, K";
      "$kbLock" = "Super, L";
      "$kbRestoreLock" = "Super+Alt, L";

      general = with config.lib.stylix.colors; {
        border_size = mkForce 2;
        gaps_in = mkForce 6;
        gaps_out = mkForce 12;
        "col.active_border" = mkForce "rgba(${base0D}ee)";
        "col.inactive_border" = mkForce "rgba(${base02}aa)";
      };

      decoration = {
        rounding = mkForce 12;
      };

      bindr = [
        "SUPER, SUPER_L, exec, caelestia shell drawers toggle launcher"
      ];

      bind = [
        "$kbSession, exec, caelestia shell drawers toggle session"
        "$kbShowPanels, exec, caelestia shell drawers showall"
      ];

      bindl = [
        "$kbClearNotifs, exec, caelestia shell notifs clear"
        "$kbRestoreLock, exec, caelestia shell -d"
        "$kbRestoreLock, exec, caelestia shell lock lock"
        ", XF86MonBrightnessUp, exec, caelestia shell brightness set +5%"
        ", XF86MonBrightnessDown, exec, caelestia shell brightness set 5%-"
        ", XF86AudioPlay, exec, caelestia shell mpris playPause"
        ", XF86AudioPause, exec, caelestia shell mpris playPause"
        ", XF86AudioNext, exec, caelestia shell mpris next"
        ", XF86AudioPrev, exec, caelestia shell mpris previous"
        ", XF86AudioStop, exec, caelestia shell mpris stop"
      ];
    };
  };
}
