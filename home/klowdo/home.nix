{
  inputs,
  lib,
  pkgs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  imports = [
    ../../modules/home-manager/stylix.nix
    inputs.catppuccin.homeModules.catppuccin
  ];

  # User-specific configuration (used by various modules)
  # home.username and home.homeDirectory are derived from userConfig
  userConfig = {
    username = "klowdo";
    fullName = "Felix Svensson";
    email = "klowdo.fs@gmail.com";
  };

  catppuccin.flavor = "macchiato";
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  # NOTE: Hyprland-specific packages are in home/features/desktop/hyprland.nix
  # NOTE: GNOME-specific packages are in home/features/desktop/gnome.nix
  home.packages = with pkgs; [
    # System info and utilities
    fastfetch
    gsettings-desktop-schemas
    duf
    ncdu
    wl-clipboard
    pciutils
    zellij
    zellij-ps

    # Archives
    unzip
    unrar
    p7zip

    # Development
    ninja
    git-absorb
    git-extras

    # Hardware
    brightnessctl
    virt-viewer
    appimage-run

    # Browser
    brave

    # Communication
    slack
    bluetuith

    # Audio
    pavucontrol

    # YubiKey
    yubikey-agent
    yubico-pam
    yubikey-manager
    yubioath-flutter
    pcsclite

    # Nix tools
    nix-search-cli
    nix-search-tv

    # Other
    circumflex
    numara-calculator
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

  # XDG portal configuration is handled by desktop feature modules:
  # - Hyprland: home/features/desktop/hyprland.nix
  # - GNOME: home/features/desktop/gnome.nix

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
  };
  # program.firefox.enable = true;

  programs.btop = {
    enable = true;
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
  # NH_FLAKE and PROJECT_FOLDERS are set by userConfig module
  home.sessionVariables = {
    NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
    NIXOS_OZONE_WL = "1";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
