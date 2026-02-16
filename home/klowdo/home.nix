{
  inputs,
  lib,
  pkgs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  imports = [
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
  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      fastfetch
      gsettings-desktop-schemas
      wlr-randr
      ydotool
      # hyprland-share-picker
      bluetuith

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

      # wezterm
      cool-retro-term
      swww
      grim

      pavucontrol
      wofi-pass
      wofi-emoji

      nix-search-cli
      nix-search-tv
      circumflex
      numara-calculator
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      ".face".source = ../../lib/felix_evolve.jpg;
      ".face.icon".source = ../../lib/felix_evolve.jpg;
      ".ssh/id_ed25519.pub".source = ./keys/id_ed25519.pub;
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
    sessionVariables = {
      NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
      NIXOS_OZONE_WL = "1";
    };
  };

  # for screensharing
  xdg = {
    portal = {
      enable = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = ["gtk" "hyprland"];
      };
      extraPortals = with pkgs; [
        # xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
  };

  programs.btop = {
    enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
