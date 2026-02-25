{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.thunar;
in {
  options.features.desktop.thunar.enable = mkEnableOption "Thunar file manager configuration";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.thunar-vcs-plugin # Git/SVN integration
      xfce.thunar-media-tags-plugin # Media file tagging
      xfce.tumbler
      # papirus-icon-theme
      # catppuccin-papirus-folders
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
      file://${config.home.homeDirectory}/Pictures Pictures
      file://${config.home.homeDirectory}/dev/worldstream Worldstream
    '';

    # Let Thunar manage its own config files since it writes to them at runtime
    # Use home.activation to set initial configs only if they don't exist
    home.activation.thunarConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
          THUNAR_DIR="$HOME/.config/Thunar"
          XFCE_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

          # Create directories if they don't exist
          mkdir -p "$THUNAR_DIR"
          mkdir -p "$XFCE_DIR"

          # Only create uca.xml if it doesn't exist
          if [ ! -f "$THUNAR_DIR/uca.xml" ]; then
            cat > "$THUNAR_DIR/uca.xml" <<'EOF'
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <command>kitty --working-directory %f</command>
          <description>Open terminal in this directory</description>
          <patterns>*</patterns>
          <directories/>
        </action>
      </actions>
      EOF
          fi

          # Only create thunar.xml if it doesn't exist
          if [ ! -f "$XFCE_DIR/thunar.xml" ]; then
            cat > "$XFCE_DIR/thunar.xml" <<'EOF'
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="thunar" version="1.0">
        <property name="last-view" type="string" value="ThunarIconView"/>
        <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_100_PERCENT"/>
        <property name="last-separator-position" type="int" value="200"/>
        <property name="last-show-hidden" type="bool" value="false"/>
        <property name="last-side-pane" type="string" value="ThunarShortcutsPane"/>
        <property name="last-sort-column" type="string" value="THUNAR_COLUMN_NAME"/>
        <property name="last-sort-order" type="string" value="GTK_SORT_ASCENDING"/>
        <property name="misc-single-click" type="bool" value="false"/>
        <property name="misc-thumbnail-mode" type="string" value="THUNAR_THUMBNAIL_MODE_ALWAYS"/>
        <property name="misc-text-beside-icons" type="bool" value="false"/>
        <property name="misc-date-style" type="string" value="THUNAR_DATE_STYLE_YYYYMMDD"/>
        <property name="misc-folders-first" type="bool" value="true"/>
        <property name="misc-horizontal-wheel-navigates" type="bool" value="false"/>
        <property name="misc-recursive-permissions" type="string" value="THUNAR_RECURSIVE_PERMISSIONS_ALWAYS"/>
        <property name="misc-remember-geometry" type="bool" value="true"/>
        <property name="misc-directory-specific-settings" type="bool" value="true"/>
        <property name="misc-full-path-in-title" type="bool" value="false"/>
        <property name="misc-image-preview-mode" type="string" value="THUNAR_IMAGE_PREVIEW_MODE_EMBEDDED"/>
        <property name="misc-middle-click-in-tab" type="bool" value="true"/>
        <property name="misc-open-new-window-as-tab" type="bool" value="true"/>
        <property name="misc-recursive-search" type="string" value="THUNAR_RECURSIVE_SEARCH_ALWAYS"/>
        <property name="shortcuts-icon-size" type="string" value="THUNAR_ICON_SIZE_32"/>
        <property name="tree-icon-size" type="string" value="THUNAR_ICON_SIZE_16"/>
      </channel>
      EOF
          fi
    '';
  };
}
