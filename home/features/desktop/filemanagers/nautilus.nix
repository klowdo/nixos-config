{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.nautilus;
in {
  options.features.desktop.nautilus.enable = mkEnableOption "Nautilus file manager configuration";

  config = mkIf cfg.enable {
    # Install Nautilus and extensions
    home.packages = with pkgs; [
      nautilus
      sushi # Quick previewer
      nautilus-python # Python extension bindings
      nautilus-open-any-terminal
    ];

    # GTK icon theme (matching Thunar configuration)
    gtk.iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "mocha";
      };
    };

    # GTK bookmarks (shared with Thunar)
    home.file.".config/gtk-3.0/bookmarks".text = ''
      file://${config.home.homeDirectory}/Downloads Downloads
      file://${config.home.homeDirectory}/Documents Documents
      file://${config.home.homeDirectory}/Pictures Pictures
      file://${config.home.homeDirectory}/dev/worldstream Worldstream
      file://${config.home.homeDirectory}/.dotfiles Dotfiles
    '';

    # Configure Nautilus preferences via dconf
    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        search-filter-time-type = "last_modified";
        show-hidden-files = false;
        sort-directories-first = true;
      };

      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;
        default-zoom-level = "small";
      };

      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "standard";
      };

      # Configure Sushi (quick preview)
      "org/gnome/sushi" = {
        # Sushi uses default GNOME settings
      };
    };
  };
}
