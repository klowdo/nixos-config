{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.yabai;
in {
  config = mkIf cfg.enable {
    home.file.".config/skhd/skhdrc" = {
      force = true;
      # launchd gives skhd a minimal PATH, so resolve yabai explicitly.
      text = builtins.replaceStrings ["yabai -m"] ["/opt/homebrew/bin/yabai -m"] ''
        # skhd Configuration
        # Hotkey daemon for yabai (mirrors Hyprland keybindings)

        # Mod keys:
        # alt      = Option key (Hyprland Super equivalent)
        # cmd      = Command key
        # shift    = Shift key
        # ctrl     = Control key

        # ============================================
        # Window Focus (Hyprland Super+H/J/K/L)
        # ============================================
        alt - h : yabai -m window --focus west
        alt - l : yabai -m window --focus east
        alt - j : yabai -m window --focus south
        alt - k : yabai -m window --focus north

        # Fallback vim bindings
        alt - left  : yabai -m window --focus west
        alt - right : yabai -m window --focus east
        alt - down  : yabai -m window --focus south
        alt - up    : yabai -m window --focus north

        # ============================================
        # Window Swapping (Hyprland Super+Shift+H/J/K/L)
        # ============================================
        alt + shift - h : yabai -m window --swap west
        alt + shift - l : yabai -m window --swap east
        alt + shift - j : yabai -m window --swap south
        alt + shift - k : yabai -m window --swap north

        # Fallback arrow keys
        alt + shift - left  : yabai -m window --swap west
        alt + shift - right : yabai -m window --swap east
        alt + shift - down  : yabai -m window --swap south
        alt + shift - up    : yabai -m window --swap north

        # ============================================
        # Window Moving (Hyprland Super+Alt+H/J/K/L)
        # ============================================
        alt + cmd - h : yabai -m window --warp west
        alt + cmd - l : yabai -m window --warp east
        alt + cmd - j : yabai -m window --warp south
        alt + cmd - k : yabai -m window --warp north

        # Fallback arrow keys
        alt + cmd - left  : yabai -m window --warp west
        alt + cmd - right : yabai -m window --warp east
        alt + cmd - down  : yabai -m window --warp south
        alt + cmd - up    : yabai -m window --warp north

        # ============================================
        # Window Management (Hyprland Super+Q/F/etc)
        # ============================================
        alt - q : yabai -m window --close
        alt - f : yabai -m window --toggle windowed-fullscreen
        alt + shift - f : yabai -m window --toggle native-fullscreen
        alt + shift - space : yabai -m window --toggle float --grid 4:4:1:1:2:2

        # ============================================
        # Split Management (Hyprland Super+S)
        # ============================================
        alt - s : yabai -m window --toggle split
        alt - return : yabai -m space --rotate 90

        # Mirror operations (Hyprland doesn't have these but useful for tiling)
        alt + ctrl - 0x21 : yabai -m space --mirror x-axis
        alt + ctrl - 0x1E : yabai -m space --mirror y-axis

        # ============================================
        # Layout Control (Hyprland Super+M, etc)
        # ============================================
        alt - m : yabai -m space --layout "$(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')"
        alt + shift - t : yabai -m space --layout float

        # ============================================
        # Resize Windows
        # ============================================
        alt + ctrl - h : yabai -m window --resize left:-20:0; yabai -m window --resize right:-20:0
        alt + ctrl - l : yabai -m window --resize right:20:0; yabai -m window --resize left:20:0
        alt + ctrl - j : yabai -m window --resize bottom:0:20; yabai -m window --resize top:0:20
        alt + ctrl - k : yabai -m window --resize top:0:-20; yabai -m window --resize bottom:0:-20

        # ============================================
        # Workspace Navigation (Hyprland Super+[0-9])
        # ============================================
        # macOS uses Spaces (Mission Control)
        # These require System Preferences → Keyboard → Shortcuts to be configured
        # Or use built-in Space switching

        # Quick space switching (macOS native)
        alt - 0x21 : yabai -m space --focus 1   # alt + [
        alt - 0x1E : yabai -m space --focus 2   # alt + ]
        alt - 1 : yabai -m space --focus 1
        alt - 2 : yabai -m space --focus 2
        alt - 3 : yabai -m space --focus 3
        alt - 4 : yabai -m space --focus 4
        alt - 5 : yabai -m space --focus 5
        alt - 6 : yabai -m space --focus 6
        alt - 7 : yabai -m space --focus 7
        alt - 8 : yabai -m space --focus 8
        alt - 9 : yabai -m space --focus 9

        # ============================================
        # Move Window to Workspace
        # ============================================
        alt + shift + cmd - 1 : yabai -m window --space 1; yabai -m space --focus 1
        alt + shift + cmd - 2 : yabai -m window --space 2; yabai -m space --focus 2
        alt + shift + cmd - 3 : yabai -m window --space 3; yabai -m space --focus 3
        alt + shift + cmd - 4 : yabai -m window --space 4; yabai -m space --focus 4
        alt + shift + cmd - 5 : yabai -m window --space 5; yabai -m space --focus 5
        alt + shift + cmd - 6 : yabai -m window --space 6; yabai -m space --focus 6
        alt + shift + cmd - 7 : yabai -m window --space 7; yabai -m space --focus 7
        alt + shift + cmd - 8 : yabai -m window --space 8; yabai -m space --focus 8
        alt + shift + cmd - 9 : yabai -m window --space 9; yabai -m space --focus 9

        # ============================================
        # Application Launchers (Hyprland Super+T/B/E/R)
        # ============================================
        alt - t : open -a "Ghostty"
        alt - b : open -a "Firefox"
        alt - e : open -a "Finder"
        alt - r : open -a "Raycast"
        alt - c : open -a "Calculator"
        alt - n : open -a "Notes"

        # ============================================
        # Window Resize (manual sizing)
        # ============================================
        # Increase/decrease window size
        alt - 0x18 : yabai -m window --resize right:20:0; yabai -m window --resize bottom:0:20
        alt - 0x1B : yabai -m window --resize right:-20:0; yabai -m window --resize bottom:0:-20

        # ============================================
        # System Controls
        # ============================================
        # Lock screen
        alt + shift + ctrl - l : pmset displaysleepnow

        # ============================================
        # Keyboard Input Switching (mirrors Hyprland's grp:win_space_toggle)
        # ============================================
        # Switch input source/keyboard layout using Cmd+Space (native macOS)
        # Alternative: Option+Space to match Hyprland's Super+Space
        alt - space : osascript -e 'tell application "System Events" to key code 49 using command down' &
      '';
    };
  };
}
