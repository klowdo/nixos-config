{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.bambu-studio;
in {
  options.features.development.bambu-studio.enable = mkEnableOption "enable bambu-studio 3D printing slicer";

  config = mkIf cfg.enable {
    # Note: This requires enabling features.development.nix-flatpak.enable = true;
    # in Home Manager config

    # Install BambuStudio via Flatpak (preferred method)
    services.flatpak.packages = [
      {
        appId = "com.bambulab.BambuStudio";
        origin = "flathub";
      }
    ];

    # Extract and install icon from Flatpak
    home.activation.bambustudio-icon = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Extract icon from Flatpak installation
      if [ -d "/var/lib/flatpak/app/com.bambulab.BambuStudio" ] || [ -d "$HOME/.local/share/flatpak/app/com.bambulab.BambuStudio" ]; then
        # Try system installation first
        FLATPAK_DIR="/var/lib/flatpak/app/com.bambulab.BambuStudio/current/active/files"
        if [ ! -d "$FLATPAK_DIR" ]; then
          # Fall back to user installation
          FLATPAK_DIR="$HOME/.local/share/flatpak/app/com.bambulab.BambuStudio/current/active/files"
        fi
        
        if [ -d "$FLATPAK_DIR" ]; then
          # Create icon directory
          mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps"
          mkdir -p "$HOME/.local/share/icons/hicolor/128x128/apps"
          mkdir -p "$HOME/.local/share/icons/hicolor/64x64/apps"
          
          # Look for icons in common locations
          for icon_path in \
            "$FLATPAK_DIR/share/icons/hicolor/scalable/apps/com.bambulab.BambuStudio.svg" \
            "$FLATPAK_DIR/share/icons/hicolor/128x128/apps/com.bambulab.BambuStudio.png" \
            "$FLATPAK_DIR/share/icons/hicolor/64x64/apps/com.bambulab.BambuStudio.png" \
            "$FLATPAK_DIR/share/pixmaps/com.bambulab.BambuStudio.png" \
            "$FLATPAK_DIR/share/pixmaps/bambustudio.png"; do
            
            if [ -f "$icon_path" ]; then
              icon_name=$(basename "$icon_path")
              target_name="bambustudio.''${icon_name##*.}"
              
              case "$icon_path" in
                */scalable/*) cp "$icon_path" "$HOME/.local/share/icons/hicolor/scalable/apps/$target_name" ;;
                */128x128/*) cp "$icon_path" "$HOME/.local/share/icons/hicolor/128x128/apps/$target_name" ;;
                */64x64/*) cp "$icon_path" "$HOME/.local/share/icons/hicolor/64x64/apps/$target_name" ;;
                */pixmaps/*) cp "$icon_path" "$HOME/.local/share/icons/hicolor/128x128/apps/$target_name" ;;
              esac
              
              echo "Extracted icon: $icon_path -> $target_name"
            fi
          done
          
          # Update icon cache
          if command -v gtk-update-icon-cache >/dev/null 2>&1; then
            gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
          fi
        fi
      fi
    '';

    # Create desktop entry for BambuStudio
    xdg.desktopEntries.bambustudio = {
      name = "BambuStudio";
      genericName = "3D Printing Software";
      comment = "PC Software for BambuLab's 3D printers";
      exec = "${pkgs.flatpak}/bin/flatpak run com.bambulab.BambuStudio";
      icon = "bambustudio"; # Use extracted icon
      terminal = false;
      type = "Application";
      categories = ["Graphics" "3DGraphics" "Engineering"];
      mimeType = [
        "model/stl"
        "model/3mf"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "application/x-amf"
        "x-scheme-handler/bambustudio"
      ];
      startupNotify = true;
    };

    # AppImage fallback
    # home.packages = [
    #   pkgs.bambustudio-appimage
    # ];
  };
}
