{
  config,
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
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.mkDefault "klowdo";
  home.homeDirectory = lib.mkDefault "/home/klowdo";

  catppuccin.flavor = "macchiato";
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
    vesktop
    fastfetch
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
    slack
    bluetuith

    ydotool
    duf
    ncdu
    wl-clipboard
    pciutils
    zellij

    unzip
    unrar
    p7zip

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
    xdg-desktop-portal-hyprland
    firefox-wayland
    swww
    grim

    pavucontrol
    zellij-ps
    git-absorb
    wofi-pass
    wofi-emoji

    yubikey-agent
    yubico-pam
    yubikey-manager
    yubioath-flutter
    pcsclite
    # pam_u2f
    rpi-imager
    git-extras
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
  home.sessionVariables = {
    NH_FLAKE = "/home/klowdo/.dotfiles/";
    NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
    PROJECT_FOLDERS = "/home/klowdo/dev/";
    NIXOS_OZONE_WL = "1";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
