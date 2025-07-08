{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.clipboard;

  # Clipboard scripts using writeShellScriptBin
  clipboard-menu = pkgs.writeShellScriptBin "clipboard-menu" ''
    # Show clipboard history using wofi
    ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu --prompt "📋 Clipboard:" --lines 15 --width 800 --height 400 | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  clipboard-clear = pkgs.writeShellScriptBin "clipboard-clear" ''
    # Clear clipboard history with confirmation
    if ${pkgs.wofi}/bin/wofi --dmenu --prompt "Clear clipboard history? (y/N):" --lines 1 --width 400 <<< "y" | grep -q "y"; then
      ${pkgs.cliphist}/bin/cliphist wipe
      ${pkgs.libnotify}/bin/notify-send "Clipboard" "History cleared" --icon=edit-clear
    fi
  '';

  clipboard-delete = pkgs.writeShellScriptBin "clipboard-delete" ''
    # Delete specific clipboard entry
    ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu --prompt "🗑️ Delete:" --lines 15 --width 800 --height 400 | ${pkgs.cliphist}/bin/cliphist delete
  '';

  clipboard-show = pkgs.writeShellScriptBin "clipboard-show" ''
    # Show current clipboard content
    current=$(${pkgs.wl-clipboard}/bin/wl-paste)
    if [ -n "$current" ]; then
      echo "$current" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "📄 Current clipboard:" --lines 10 --width 800 --height 300
    else
      ${pkgs.libnotify}/bin/notify-send "Clipboard" "Empty" --icon=dialog-information
    fi
  '';
in {
  options.features.desktop.clipboard = {
    enable = mkEnableOption "clipboard manager";

    allowImages = mkOption {
      type = types.bool;
      default = true;
      description = "Store images in clipboard history";
    };
  };

  config = mkIf cfg.enable {
    # Enable cliphist service via Home Manager
    services.cliphist = {
      enable = true;
      inherit (cfg) allowImages;
      extraOptions = [
        "-max-items"
        "1000"
        "-max-dedupe-search"
        "100"
      ];
    };

    # Install required packages and scripts
    home.packages = with pkgs; [
      cliphist # Wayland clipboard manager
      wl-clipboard # Wayland clipboard utilities
      libnotify # For notifications

      # Clipboard scripts
      clipboard-menu
      clipboard-clear
      clipboard-delete
      clipboard-show
    ];

    # Shell aliases for convenience
    home.shellAliases = {
      "clip" = "wl-copy";
      "clipb" = "wl-paste";
      "clip-menu" = "clipboard-menu";
      "clip-clear" = "clipboard-clear";
      "clip-delete" = "clipboard-delete";
      "clip-show" = "clipboard-show";
    };

    # XDG desktop entry for GUI access
    xdg.desktopEntries = {
      clipboard-manager = {
        name = "Clipboard Manager";
        comment = "Browse clipboard history";
        exec = "clipboard-menu";
        icon = "edit-paste";
        categories = ["Utility" "System"];
      };
    };
  };
}

