{lib, pkgs, ...}: {
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

  # Override xdg portal for GNOME (disable Hyprland portal from home.nix)
  xdg.portal = lib.mkForce {
    enable = true;
    config = {
      common.default = ["gtk"];
      gnome.default = ["gtk" "gnome"];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # Override home packages to remove Hyprland-specific ones
  home.packages = lib.mkForce (with pkgs; [
    fastfetch
    gsettings-desktop-schemas

    duf
    ncdu
    wl-clipboard
    pciutils
    zellij

    unzip
    unrar
    p7zip

    brightnessctl
    virt-viewer
    appimage-run

    brave

    pavucontrol

    gnome-tweaks
    dconf-editor
  ]);
}
