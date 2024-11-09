{config, ...}: {
  imports = [
    ./home.nix
    ./dotfiles
    ../features
    ../common
  ];

  features = {
    cli = {
      zsh.enable = true;
      neofetch.enable = true;
      fzf.enable = true;
      yazi.enable = true;
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      fonts.enable = true;
    };
    development = {
      tools = {
        rider.enable = true;
      };
      languages = {
        dotnet.enable = true;
      };
    };
    media = {
      spicetify.enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      input = {
        touchpad = {scroll_factor = 0.2;};
      };
      device = [
        {
          name = "keyboard";
        }
        {
          name = "mouse";
          sensitivity = -0.5;
        }
      ];
      workspace = [
        "1, monitor:eDP-1, default:true"
        "2, monitor:eDP-1"
        "3, monitor:eDP-1"
        "4, monitor:eDP-2"
        "5, monitor:eDP-1"
        "6, monitor:eDP-2"
        "7, monitor:eDP-2"
      ];
    };
  };
}
