{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.yabai;
in {
  imports = [./skhd.nix];

  options.features.desktop.yabai = {
    enable = mkEnableOption "Yabai - macOS tiling window manager";
  };

  config = mkIf cfg.enable {
    home.file.".config/yabai/yabairc" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # launchd starts yabai with a minimal PATH; the config must find Homebrew's binary.
        export PATH="/opt/homebrew/bin:$PATH"

        # Yabai Configuration
        # Mirrors Hyprland tiling behavior on macOS

        # Default layout (mirrors Hyprland's dwindle)
        yabai -m config layout bsp
        yabai -m space 2 --layout bsp

        # Window gaps (mirror Hyprland's 4px inner, 8px outer)
        yabai -m config top_padding    8
        yabai -m config bottom_padding 8
        yabai -m config left_padding   8
        yabai -m config right_padding  8
        yabai -m config window_gap     4

        # Window opacity settings
        yabai -m config window_opacity on
        yabai -m config active_window_opacity   1.0
        yabai -m config normal_window_opacity   0.95

        # Focus follows mouse (like Hyprland)
        yabai -m config focus_follows_mouse autofocus
        yabai -m config mouse_follows_focus off

        # Split direction (like Hyprland's dwindle)
        yabai -m config split_ratio 0.5

        # Auto-balance windows (like Hyprland's dwindle.preserve_split false)
        yabai -m config auto_balance off

        # Mouse modifier (Option key = Alt, like Hyprland's Super)
        # Uses skhd for keybindings instead
        yabai -m config mouse_modifier alt
        yabai -m config mouse_action1 move
        yabai -m config mouse_action2 resize

        # Border for active window (visually similar to Hyprland's border)
        yabai -m config active_window_border_color 0xffe1e4e8
        yabai -m config normal_window_border_color 0xff424854
        yabai -m config insert_feedback_color       0xff00d4ff
        yabai -m config window_border               on
        yabai -m config window_border_placement     interior
        yabai -m config window_border_width         2

        # Floating windows (maps to Hyprland's floating rules)
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add app="^System Settings$" manage=off
        yabai -m rule --add app="^Finder$" manage=off
        yabai -m rule --add app="^Keychain Access$" manage=off
        yabai -m rule --add app="^Activity Monitor$" manage=off
        yabai -m rule --add app="^Calculator$" manage=off
        yabai -m rule --add app="^Xcode$" manage=off
        yabai -m rule --add app="^RapidWeaver$" manage=off

        # Floating for chats and notif apps
        yabai -m rule --add app="^Discord$" manage=off
        yabai -m rule --add app="^Zoom$" manage=off
        yabai -m rule --add app="^Telegram$" manage=off

        # Send new app windows to their designated Spaces.
        yabai -m rule --add app="^Slack$" manage=on space=3
        yabai -m rule --add app="^Microsoft Teams$" space=3
        yabai -m rule --add app="^Spotify$" space=4
        yabai -m rule --add app="^Firefox$" manage=on space=2

        # Signals - refresh on space/window events
        yabai -m signal --add event=dock_did_restart action="sudo yabai --restart-service"
        yabai -m signal --add event=window_destroyed active=yes action="yabai -m query --windows --window &> /dev/null && yabai -m window --focus mouse &> /dev/null || true"
        yabai -m signal --add event=window_minimized active=yes action="yabai -m query --windows --window &> /dev/null && yabai -m window --focus mouse &> /dev/null || true"

        echo "yabai configuration loaded"
      '';
    };

    home.file.".config/yabai/KEYBINDINGS.md" = {
      text = ''
        # Yabai + skhd Keybindings
        ## Mapping from Hyprland to Yabai

        ### Window Navigation (Hyprland → Yabai)
        - Hyprland: Super+H → Yabai: Option+H (focus left)
        - Hyprland: Super+L → Yabai: Option+L (focus right)
        - Hyprland: Super+K → Yabai: Option+K (focus up)
        - Hyprland: Super+J → Yabai: Option+J (focus down)

        ### Window Management
        - Hyprland: Super+Q → Yabai: Option+Q (close window)
        - Hyprland: Super+Shift+H/J/K/L → Yabai: Option+Shift+H/J/K/L (swap windows)
        - Hyprland: Super+Alt+H/J/K/L → Yabai: Option+Cmd+H/J/K/L (move windows)
        - Hyprland: Super+Shift+Space → Yabai: Option+Shift+Space (toggle floating)
        - Hyprland: Super+F → Yabai: Option+F (toggle fullscreen)

        ### Workspace Controls
        - Hyprland: Super+[0-9] → macOS Mission Control: Option+[1-9] (switch desktop)
        - Set these in System Settings → Keyboard → Keyboard Shortcuts → Mission Control → Switch to Desktop 1–9. They are native macOS shortcuts, not skhd/yabai bindings. The entry for a desktop may appear only after that desktop exists.
        - Hyprland: Super+Shift+Alt+[0-9] → Yabai: Option+Shift+Cmd+[1-9] (move to workspace)

        ### Layout Controls
        - Hyprland: Super+S → Yabai: Option+S (toggle split)
        - Hyprland: Super+M → Yabai: Option+M (toggle float/tile)

        ### Application Launchers
        - Hyprland: Super+T → Yabai: Option+T (terminal)
        - Hyprland: Super+B → Yabai: Option+B (browser)
        - Hyprland: Super+E → Yabai: Option+E (file manager)
        - Hyprland: Super+R → Yabai: Option+R (launcher/Raycast)

        ### Other
        - Hyprland: Super+Return → Yabai: Option+Return (rotate split)
        - Yabai: Option+Control+[ (mirror vertical)
        - Yabai: Option+Control+] (mirror horizontal)
      '';
    };
  };
}
