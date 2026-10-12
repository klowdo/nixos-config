{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.nautilus = {
    config,
    pkgs,
    ...
  }: {
    imports = [flake.modules.homeManager.defaults];

    features.defaults.fileManager.type = "nautilus";

    home.packages = with pkgs; [
      nautilus
      file-roller
      sushi
      nautilus-python
      nautilus-open-any-terminal
      adwaita-icon-theme
    ];

    gtk.iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "mocha";
      };
    };

    home.file.".config/gtk-3.0/bookmarks".text = ''
      file://${config.home.homeDirectory}/Downloads Downloads
      file://${config.home.homeDirectory}/Documents Documents
      file://${config.home.homeDirectory}/Pictures Pictures
      file://${config.home.homeDirectory}/dev Dev
      file://${config.home.homeDirectory}/dev/github Github
      file://${config.home.homeDirectory}/dev/work Work
      file://${config.home.homeDirectory}/.dotfiles Dotfiles
    '';

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

      "org/gnome/sushi" = {};
    };
  };
}
