{ config, ... }: {
  imports = [
    ./home.nix
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
    };
  };
}

