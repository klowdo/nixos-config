{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.gnome;
in {
  options.features.desktop.gnome.enable = mkEnableOption "GNOME desktop configuration";

  config = mkIf cfg.enable {
    # GNOME-specific packages
    home.packages = with pkgs; [
      gnome-tweaks
      dconf-editor
      gnome-extension-manager
      wl-clipboard
    ];

    # dconf settings for GNOME
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "kitty.desktop"
        ];
      };

      "org/gnome/desktop/input-sources" = {
        sources = [(mkTuple ["xkb" "us"])];
      };

      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
      };

      # Enable night light
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
      };
    };

    # Set environment variables for GNOME Wayland session
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };

    # XDG portal configuration for GNOME
    xdg.portal = {
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
  };
}
