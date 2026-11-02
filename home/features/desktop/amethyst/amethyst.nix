{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.amethyst;
in
{
  config = mkIf cfg.enable {
    # Amethyst configuration - tiling window manager for macOS
    # Mirrors Hyprland functionality on Darwin

    home.file.".config/amethyst/amethyst.yml" = {
      text = ''
        # Amethyst Configuration
        # Mirrors Hyprland tiling behavior on macOS

        # Layouts - equivalent to Hyprland's dwindle
        layouts:
          - tall       # Master + stack (similar to Hyprland dwindle)
          - wide       # Wide variant
          - fullscreen # Fullscreen focused window
          - floating   # Floating windows

        # Default layout
        layout: tall

        # Window focus follows mouse (like Hyprland)
        enable-focus-follows-mouse: true
        focus-follows-mouse-delay: 75

        # Gaps - mirror Hyprland's 4px inner, 8px outer
        window-margin-size: 8    # Outer gap (8px)
        window-padding-size: 4   # Inner gap (4px)

        # Opacity settings (macOS uses system-wide settings)
        # Can be configured via System Preferences > Accessibility > Display
        # Similar to Hyprland's active/inactive opacity

        # Automatic layout on application launch
        automatic-layout: true

        # Column count for tall and wide layouts
        column-count: 2

        # Focus follows modifier (Alt key = Hyprland's Super equivalent on macOS)
        focus-modifier: alt

        # Mod key definitions (map to Super/Alt equivalent)
        # In Amethyst preferences, map these to Option (Alt) key
        mod-key: option

        # Enable window resizing via mouse (like Hyprland's Super+mouse273)
        enable-mouse-follows-focus: false

        # Floating windows (macOS equivalents to Hyprland's floating rules)
        floating-is-blacklist: true
        floating-bundle-identifiers:
          - com.apple.systempreferences
          - com.apple.finder
          - com.apple.keychainaccess
          - com.apple.security.authorization-helper
          - com.apple.dt.Xcode  # Xcode assistant windows
          - com.jetbrains.rider # JetBrains IDE helper windows

        # Workspace names (Amethyst uses Spaces)
        # Maps to macOS's native Spaces (equivalent to Hyprland's 10 workspaces)
        # Configure in System Preferences > Mission Control > Spaces

        # Ignore certain applications (like Hyprland's windowrulev2 "tile,class:^(Spotify)$" false)
        window-minimum-width: 100
        window-minimum-height: 100

        # Logging
        enable-logging: false
        logging-level: info

        # Launch on startup
        launch-on-login: true

        # Mouse follows focus (when changing focus with keyboard)
        mouse-follows-focus: false

        # Discord and other chat apps should float by default
        # These map to Hyprland's floating window rules
        floating-bundle-identifiers:
          - com.hnc.Discord
          - us.zoom.xos
          - com.spotify.client
      '';
    };

    # Keybinding hints - document the mappings (Amethyst uses System Preferences)
    home.file.".config/amethyst/KEYBINDINGS.md" = {
      text = ''
        # Amethyst Keybindings
        ## Mapping from Hyprland to Amethyst

        ### Window Navigation (Hyprland → Amethyst)
        - Hyprland: Super+H/J/K/L → Amethyst: Option+H/J/K/L (set in Amethyst prefs)
        - Hyprland: Super+[0-9] → Amethyst: Option+[1-9] (Spaces navigation)
        - Hyprland: Super+Q → Close window

        ### Window Management
        - Hyprland: Super+S → Split/unsplit window
        - Hyprland: Super+F → Toggle fullscreen → Amethyst: Option+Return (toggles fullscreen layout)
        - Hyprland: Super+Shift+Space → Toggle floating → Not directly available in Amethyst
        - Hyprland: Super+M → Toggle master layout → Amethyst: Option+U (cycle layouts)

        ### Layout Controls
        - Hyprland: CTRL+SHIFT+ALT+SUPER+; → Toggle animation preset
          → Amethyst: Option+U (cycles layouts: tall → wide → fullscreen → floating)

        ### Recommended Amethyst Setup
        Configure in System Preferences > Keyboard > Shortcuts > App Shortcuts:
        1. Set focus modifier to Option (Alt) key
        2. Bind Option+H/J/K/L for window focus
        3. Bind Option+Shift+H/J/K/L for window moving
        4. Bind Option+U to cycle layouts (matches Hyprland animation toggle conceptually)

        ### Notes
        - macOS native Spaces replace Hyprland's workspaces
        - Configure Space count in System Preferences > Mission Control
        - Window rules use Amethyst's floating list (similar to Hyprland's windowrulev2)
        - Floating toggle can be manual via Amethyst menu or by adding to floating list
      '';
    };

    # Optional: Create a startup script to ensure Amethyst preferences are set
    home.file.".config/amethyst/setup.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Amethyst initial setup script
        # This ensures key system preferences are configured to work with Amethyst

        # Enable Amethyst to control windows via accessibility
        echo "Amethyst requires: System Preferences > Security & Privacy > Accessibility"
        echo "Please add Amethyst to the allowed apps list"

        # Configure Mission Control for multiple spaces (Hyprland equivalent)
        echo "Recommended: System Preferences > Mission Control > Spaces (set to 10 like Hyprland)"

        # Open Amethyst preferences if installed
        if [ -d "/Applications/Amethyst.app" ]; then
          open /Applications/Amethyst.app
          open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        fi
      '';
    };

    # Home Manager state
    home.stateVersion = "26.05";
  };
}
