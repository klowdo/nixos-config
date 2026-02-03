{...}: {
  imports = [
    ./home.nix
    ./dotfiles
    ../features
    ../common
    ../common/optional/sops.nix
  ];

  features = {
    cli = {
      zsh.enable = true;
      neofetch.enable = true;
      fzf.enable = true;
      kitty.enable = true;
      gh.enable = true;
      lazygit.enable = true;
    };
    desktop = {
      gnome.enable = true;
      fonts.enable = true;
    };
  };
}
