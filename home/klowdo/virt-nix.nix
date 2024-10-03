{ config, ... }: {
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
  };

  wayland.windowManager.hyprland = {
    settings = {
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
        "DP-1,1920x1080@60,0x0,1"
      ];
      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-2"
        "5, monitor:DP-1"
        "6, monitor:DP-2"
        "7, monitor:DP-2"
      ];
    };
  };
}

