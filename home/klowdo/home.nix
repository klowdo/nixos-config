{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../nixvim/nixvim.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.mkDefault "${config.home.username}";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    kitty
    wofi
    lazygit
    nh
    eza
    spotify
    gsettings-desktop-schemas
    swaynotificationcenter
    wlr-randr
    ydotool
    # hyprland-share-picker
    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper

    ydotool
    duf
    ncdu
    wl-clipboard
    pciutils
    tmux

    unzip
    unrar

    ninja
    brightnessctl
    virt-viewer
    swappy
    appimage-run

    brave

    # wezterm
    cool-retro-term
    wl-clipboard
    hyprland-protocols
    hyprpicker
    swayidle
    swaylock
    xdg-desktop-portal-hyprland
    hyprpaper
    firefox-wayland
    swww
    grim

    pavucontrol
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
  # program.firefox.enable = true;
  programs.git = {
    enable = true;
    userName = "Felix Svensson";
    userEmail = "klowdo.fs@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/m3tam3re/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    FLAKE = "/home/${config.home.username}/.dotfiles/";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
