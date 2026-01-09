{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./home.nix
    ./dotfiles
    ./dellicious-monitors.nix
    ../features
    ../common
    ../common/optional/sops.nix
    ../common/optional/vial.nix
  ];

  features = {
    cli = {
      kitty.enable = true;
      zsh.enable = true;
      neofetch.enable = true;
      fzf.enable = true;
      yazi.enable = true;
      password-store.enable = false;
      taskwarrior.enable = true;
      tmux.enable = true;
      gh.enable = true;
      claude-code.enable = true;
      bitwarden-wofi.enable = true;
      ssh.enable = true;
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      fonts.enable = true;
      tailscale-systray.enable = true;
      clipboard.enable = true;
      calculator.enable = true;
      todo.enable = true;
      nautilus.enable = true;
      darkman.enable = true;
      bitwarden.enable = true;
      vicinae = {
        enable = true;
        enableHyprlandSupport = true;
      };
      bar = {
        hyprpanel.enable = true;
        # ashell.enable = true; 
      };
    };

    defaults = {
      enable = true;
      launcher = {
        command = "vicinae toggle";
        inherit (config.programs.vicinae) package;
        # "${pkgs.killall}/bin/killall wofi || wofi --show drun --allow-images"
        dmenuMode = "vicinae dmenu";
      };
      browser = {
        command = "firefox";
        package = pkgs.firefox;
      };
      terminal = {
        command = "kitty";
        package = pkgs.kitty;
      };
    };
    development = {
      tools = {
        rider.enable = false;
        goland.enable = true;
        libreoffice.enable = true;
      };
      languages = {
        dotnet.enable = true;
      };
      cura.enable = true;
      orca.enable = true;
      super-slicer.enable = true;
      bambu-studio.enable = true;
      nix-flatpak.enable = true;
      freecad.enable = true;
      mongo-compass.enable = true;
    };
    media = {
      spicetify.enable = true;
      spotify-player.enable = true;
      zathura.enable = true;
      deezer.enable = true;
      music-assistant = {
        enable = true;
        url = "https://music.home.flixen.se";
      };
      pinta.enable = true;
    };
    communication = {
      zoom.enable = false;
      vesktop.enable = true;
      neomutt.enable = false;
    };
    hardware = {
      zsa-moonlander.enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      input = {
        touchpad = {
          scroll_factor = 0.2;
          disable_while_typing = true;
        };
        kb_layout = "us,se";
        kb_options = "grp:win_space_toggle,ctrl:nocaps";
        follow_mouse = 1;
        float_switch_override_focus = 0;

        sensitivity = 0;
      };

      device = [
        {
          name = "zsa-technology-labs-moonlander-mark-i-keyboard";
          kb_layout = "us,se";
        }
        {
          name = "zsa-technology-labs-moonlander-mark-i";
          kb_layout = "us,se";
        }
        {
          name = "mouse";
          sensitivity = -0.5;
        }
      ];
      # workspace = [
      #   "1, monitor:eDP-1, default:true"
      #   "2, monitor:eDP-1"
      #   "3, monitor:eDP-1"
      #   "4, monitor:eDP-2"
      #   "5, monitor:eDP-1"
      #   "6, monitor:eDP-2"
      #   "7, monitor:eDP-2"
      # ];
    };
  };

  # Disabled in favor of hyprdynamicmonitors - kept for reference during migration
  # services.custom-way-displays = {
  #   arrange = "COLUMN";
  #   align = "MIDDLE";
  #   scaling = true;
  #   autoScale = false;
  #   autoScaleMin = 1.0;
  #   order = [
  #     "!.*$"
  #     "DP-7"
  #     "eDP-1"
  #   ];
  #   scales = [
  #     {
  #       # Internal
  #       nameDesc = "Samsung Display Corp. 0x414D";
  #       scale = 1.5;
  #     }
  #     {
  #       # home TV
  #       nameDesc = "Samsung Electric Company SAMSUNG 0x01000E00";
  #       scale = 1.5;
  #     }
  #     {
  #       # Work
  #       nameDesc = "Samsung Electric Company LU28R55 H4ZT400162";
  #       scale = 1.0;
  #     }
  #     {
  #       # Home monitor
  #       nameDesc = "HP Inc. HP Z40c G3 CN43090Z36";
  #       scale = 1.0;
  #     }
  #     {
  #       # Office thunderbold
  #       nameDesc = "Dell Inc. DELL U2724DE 42QR734";
  #       scale = 1.0;
  #     }
  #   ];
  #   modes = [
  #     {
  #       # Internal
  #       nameDesc = "Samsung Display Corp. 0x414D";
  #       width = 3456;
  #       height = 2160;
  #       hz = 60;
  #       max = true;
  #     }
  #     {
  #       # Home Tv
  #       nameDesc = "Samsung Electric Company SAMSUNG 0x01000E00";
  #       width = 3840;
  #       height = 2160;
  #       hz = 30;
  #       # max = true;
  #     }
  #     {
  #       # Home monitor
  #       nameDesc = "HP Inc. HP Z40c G3 CN43090Z36";
  #       max = true;
  #     }
  #
  #     {
  #       # Office thunderbold
  #       nameDesc = "Dell Inc. DELL U2724DE 42QR734";
  #       max = true;
  #     }
  #
  #     # Office
  #     {
  #       nameDesc = "Dell Inc. DELL U2724D BW25834";
  #       max = true;
  #     }
  #   ];
  #   vrrOff = ["!.*$"];
  # };
}
