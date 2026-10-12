{...}: {
  flake.modules.homeManager.clipboard = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.desktop.clipboard;

      clipboard-menu = pkgs.writeShellScriptBin "clipboard-menu" ''
        ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu --prompt "📋 Clipboard:" --lines 15 --width 800 --height 400 | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      clipboard-clear = pkgs.writeShellScriptBin "clipboard-clear" ''
        if ${pkgs.wofi}/bin/wofi --dmenu --prompt "Clear clipboard history? (y/N):" --lines 1 --width 400 <<< "y" | grep -q "y"; then
          ${pkgs.cliphist}/bin/cliphist wipe
          ${pkgs.libnotify}/bin/notify-send "Clipboard" "History cleared" --icon=edit-clear
        fi
      '';

      clipboard-delete = pkgs.writeShellScriptBin "clipboard-delete" ''
        ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu --prompt "🗑️ Delete:" --lines 15 --width 800 --height 400 | ${pkgs.cliphist}/bin/cliphist delete
      '';

      clipboard-show = pkgs.writeShellScriptBin "clipboard-show" ''
        current=$(${pkgs.wl-clipboard}/bin/wl-paste)
        if [ -n "$current" ]; then
          echo "$current" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "📄 Current clipboard:" --lines 10 --width 800 --height 300
        else
          ${pkgs.libnotify}/bin/notify-send "Clipboard" "Empty" --icon=dialog-information
        fi
      '';
    in {
      options.features.desktop.clipboard.allowImages = mkOption {
        type = types.bool;
        default = true;
        description = "Store images in clipboard history";
      };

      config = {
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

        home.packages = with pkgs; [
          cliphist
          wl-clipboard
          libnotify
          clipboard-menu
          clipboard-clear
          clipboard-delete
          clipboard-show
        ];

        home.shellAliases = {
          "clip" = "wl-copy";
          "clipb" = "wl-paste";
          "clip-menu" = "clipboard-menu";
          "clip-clear" = "clipboard-clear";
          "clip-delete" = "clipboard-delete";
          "clip-show" = "clipboard-show";
        };

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
    };
}
