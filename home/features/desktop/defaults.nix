{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.defaults;
in {
  options.features.defaults = {
    enable = mkEnableOption "Enable default applications configuration";

    launcher = {
      command = mkOption {
        type = types.str;
        default = "wofi";
        example = "rofi";
        description = "Command for application launcher";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.wofi;
        example = "pkgs.rofi";
        description = "Package for the launcher";
      };

      dmenuMode = mkOption {
        type = types.str;
        default = "wofi -i -M fuzzy -d --hide-scroll --allow-markup --width=650 --height=400";
        example = "rofi -dmenu -i -p";
        description = "Dmenu-compatible mode arguments for the launcher";
      };
    };

    browser = {
      command = mkOption {
        type = types.str;
        default = "google-chrome-stable";
        example = "firefox";
        description = "Command for web browser";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.google-chrome;
        example = "pkgs.firefox";
        description = "Package for the browser";
      };
    };

    terminal = {
      command = mkOption {
        type = types.str;
        default = "kitty";
        example = "alacritty";
        description = "Command for terminal emulator";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.kitty;
        example = "pkgs.alacritty";
        description = "Package for the terminal";
      };
    };

    fileManager = {
      command = mkOption {
        type = types.str;
        default = "thunar";
        example = "dolphin";
        description = "Command for file manager";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.xfce.thunar;
        example = "pkgs.dolphin";
        description = "Package for the file manager";
      };
    };

    editor = {
      command = mkOption {
        type = types.str;
        default = "nvim";
        example = "code";
        description = "Command for text editor";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.neovim;
        example = "pkgs.vscode";
        description = "Package for the editor";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install the configured packages
    home = {
      packages = [
        cfg.launcher.package
        cfg.browser.package
        cfg.terminal.package
        cfg.fileManager.package
        cfg.editor.package
      ];

      # Set environment variables
      sessionVariables = {
        BROWSER = cfg.browser.command;
        TERMINAL = cfg.terminal.command;
        EDITOR = cfg.editor.command;
        VISUAL = cfg.editor.command;

        # Custom variables for scripts
        DEFAULT_LAUNCHER = cfg.launcher.command;
        DEFAULT_DMENU = cfg.launcher.dmenuMode;
        DEFAULT_FILE_MANAGER = cfg.fileManager.command;
      };

      # Create a shell script that can be sourced by other scripts
      file.".config/defaults.sh" = {
        text = ''
          #!/usr/bin/env bash
          # Auto-generated default applications configuration
          # Source this file in your scripts: source ~/.config/defaults.sh

          export BROWSER="${cfg.browser.command}"
          export TERMINAL="${cfg.terminal.command}"
          export EDITOR="${cfg.editor.command}"
          export VISUAL="${cfg.editor.command}"
          export DEFAULT_LAUNCHER="${cfg.launcher.command}"
          export DEFAULT_DMENU="${cfg.launcher.dmenuMode}"
          export DEFAULT_FILE_MANAGER="${cfg.fileManager.command}"

          # Helper function for dmenu-style selection
          dmenu_select() {
            local prompt="$1"
            shift
            printf '%s\n' "$@" | ${cfg.launcher.dmenuMode} -p "$prompt"
          }
        '';
        executable = false;
      };
    };

    # XDG MIME type associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = ["${cfg.browser.command}.desktop"];
        "x-scheme-handler/http" = ["${cfg.browser.command}.desktop"];
        "x-scheme-handler/https" = ["${cfg.browser.command}.desktop"];
        "x-scheme-handler/about" = ["${cfg.browser.command}.desktop"];
        "x-scheme-handler/unknown" = ["${cfg.browser.command}.desktop"];

        "text/plain" = ["${cfg.editor.command}.desktop"];

        "inode/directory" = ["${cfg.fileManager.command}.desktop"];
      };
    };

    # XDG user directories
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
