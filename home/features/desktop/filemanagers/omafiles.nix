{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.omafiles;

  # Reverse-DNS id: D-Bus activation only works when the .desktop basename is the
  # same bus name that scripts/dbus-app-open.py owns.
  appId = "io.github.percius04.omafiles";

  scripts = "${pkgs.omafiles}/share/omafiles/scripts";
in {
  options.features.desktop.omafiles = {
    enable = mkEnableOption "Omafiles file manager configuration";

    fileChooserPortal = mkEnableOption ''
      Omafiles as the xdg-desktop-portal FileChooser backend, replacing the GTK
      file dialog in portal-aware applications
    '';

    stylixTheme = mkOption {
      type = types.bool;
      default = options ? stylix;
      description = "Derive the Omafiles palette from the Stylix base16 scheme";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      omafiles
      file-roller # handler for the archive mime types (see defaults.nix)
      adwaita-icon-theme # fallback icons for apps not in Papirus
    ];

    # GTK icon theme (matching the Thunar/Nautilus configuration). Omafiles draws
    # its own icons from the nerd font, but GTK apps around it still need one.
    gtk.iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "mocha";
      };
    };

    # GTK bookmarks (shared with Thunar/Nautilus). Omafiles keeps its own
    # bookmarks in ~/.local/state/omafiles/bookmarks.json and edits them at
    # runtime, so those are deliberately left unmanaged.
    home.file.".config/gtk-3.0/bookmarks".text = ''
      file://${config.home.homeDirectory}/Downloads Downloads
      file://${config.home.homeDirectory}/Documents Documents
      file://${config.home.homeDirectory}/Pictures Pictures
      file://${config.home.homeDirectory}/dev Dev
      file://${config.home.homeDirectory}/dev/github Github
      file://${config.home.homeDirectory}/dev/work Work
      file://${config.home.homeDirectory}/.dotfiles Dotfiles
    '';

    # Omafiles takes its palette from the Omarchy theme state directory
    # (app/qml_modules/qs/Commons/ThemeSource.qml); nothing else writes that path
    # on NixOS, so feed it the Stylix colours to match the rest of the desktop.
    # Without the file the app falls back to its own built-in dark theme.
    home.file.".local/state/omarchy/current/theme/colors.toml" = mkIf cfg.stylixTheme {
      text = with config.lib.stylix.colors; ''
        foreground = "#${base05}"
        background = "#${base00}"
        accent = "#${base0D}"
        muted = "#${base03}"
        red = "#${base08}"
      '';
    };

    # Upstream self-registers as file manager on every start via
    # scripts/install-integrations.sh (it rewrites the .desktop, the D-Bus
    # services and the portal config under $HOME). That call is patched out in
    # pkgs/omafiles, and the same integrations are declared here instead.
    xdg.desktopEntries.${appId} = {
      name = "Omafiles";
      genericName = "File manager";
      comment = "Keyboard-first, tileable Qt6 file manager";
      # open-path.sh decodes file:// URIs and folds a file argument to its parent
      # directory before handing off to the single instance.
      exec = "${scripts}/open-path.sh %u";
      icon = "omafiles";
      terminal = false;
      type = "Application";
      categories = ["System" "FileManager"];
      mimeType = ["inode/directory"];
      settings = {
        DBusActivatable = "true";
        StartupWMClass = "omafiles";
      };
    };

    # org.freedesktop.Application - Firefox/GTK "open containing folder"
    # activates the default file manager over D-Bus rather than exec'ing it, and
    # only does so for DBusActivatable entries.
    xdg.dataFile."dbus-1/services/${appId}.service".text = ''
      [D-BUS Service]
      Name=${appId}
      Exec=${scripts}/dbus-app-open.py
    '';

    # org.freedesktop.FileManager1 - "Show in file manager" of GTK/Qt apps.
    # Takes over the bus name from Nautilus when both are installed.
    xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".text = ''
      [D-BUS Service]
      Name=org.freedesktop.FileManager1
      Exec=${scripts}/dbus-filemanager1.py
    '';

    xdg.dataFile."dbus-1/services/org.freedesktop.impl.portal.desktop.omafiles.service" = mkIf cfg.fileChooserPortal {
      text = ''
        [D-BUS Service]
        Name=org.freedesktop.impl.portal.desktop.omafiles
        Exec=${scripts}/dbus-filechooser.py
      '';
    };

    xdg.dataFile."xdg-desktop-portal/portals/omafiles.portal" = mkIf cfg.fileChooserPortal {
      text = ''
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.omafiles
        Interfaces=org.freedesktop.impl.portal.FileChooser;
        UseIn=Hyprland;
      '';
    };

    xdg.portal.config.hyprland = mkIf cfg.fileChooserPortal {
      "org.freedesktop.impl.portal.FileChooser" = "omafiles";
    };
  };
}
