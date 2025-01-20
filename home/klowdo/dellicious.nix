{config, ...}: {
  imports = [
    ./home.nix
    ./dotfiles
    ../features
    ../common
  ];

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
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      fonts.enable = true;
    };
    development = {
      tools = {
        rider.enable = true;
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
      discord.enable = true;
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
}
