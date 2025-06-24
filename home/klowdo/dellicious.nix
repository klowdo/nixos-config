{...}: {
  imports = [
    ./home.nix
    ./dotfiles
    ../features
    ../common
    ../common/optional/sops.nix
    ../common/optional/vial.nix
  ];

  hyprpanel.enable = true;

  features = {
    cli = {
      kitty.enable = true;
      zsh.enable = true;
      neofetch.enable = true;
      fzf.enable = true;
      yazi.enable = true;
      password-store.enable = true;
      taskwarrior.enable = true;
      tmux.enable = true;
      gh.enable = true;
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      fonts.enable = true;
    };
    development = {
      tools = {
        rider.enable = false;
        libreoffice.enable = true;
      };
      languages = {
        dotnet.enable = true;
      };
    };
    media = {
      spicetify.enable = true;
      zathura.enable = true;
    };
    communication = {
      zoom.enable = true;
      vesktop.enable = true;
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

  services.custom-way-displays = {
    arrange = "ROW";
    align = "TOP";
    scaling = true;
    autoScale = false;
    autoScaleMin = 1.0;
    scales = [
      {
        # Internal
        nameDesc = "Samsung Display Corp. 0x414D";
        scale = 1.5;
      }
      {
        # home TV
        nameDesc = "Samsung Electric Company SAMSUNG 0x01000E00";
        scale = 1.5;
      }
      {
        # Work
        nameDesc = "Samsung Electric Company LU28R55 H4ZT400162";
        scale = 1.0;
      }
      {
        # Home monitor
        nameDesc = "HP Inc. HP Z40c G3 CN43090Z36";
        scale = 1.0;
      }
    ];
    modes = [
      {
        # Internal
        nameDesc = "Samsung Display Corp. 0x414D";
        width = 3456;
        height = 2160;
        hz = 60;
        max = true;
      }
      {
        # Work
        nameDesc = "Samsung Electric Company LU28R55 H4ZT400162";
        max = true;
      }
      {
        # Home Tv
        nameDesc = "Samsung Electric Company SAMSUNG 0x01000E00";
        width = 3840;
        height = 2160;
        hz = 30;
        # max = true;
      }
      {
        # Home monitor
        nameDesc = "HP Inc. HP Z40c G3 CN43090Z36";
        max = true;
      }
    ];
    vrrOff = ["eDP-1" "DP-4"];
  };
}
