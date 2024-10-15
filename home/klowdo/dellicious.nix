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
  };

  wayland.windowManager.hyprland = let
    laptopMonitor = "eDP-1,3456x2160@60,0x0,1.5";
  in {
    settings = {
      input = {
        touchpad = {scroll_factor = 0.2;};
      };
      device = [
        {
          name = "keyboard";
          kb_layout = "us";
        }
        {
          name = "mouse";
          sensitivity = -0.5;
        }
      ];
      monitor = [
        laptopMonitor
        "DP-1,1920x1080@60,0x0,1"
      ];
      bindl = [
        ", switch:off:Lid Switch,exec,hyprctl keyword monitor \"${laptopMonitor}\""
        # trigger when the switch is turning on
        ", switch:on:Lid Switch,exec,hyprctl keyword monitor \"eDP-1, disable\""
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
