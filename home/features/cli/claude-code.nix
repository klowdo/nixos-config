{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.claude-code;
  claudeCodeVersion = "1.0.90";
in {
  options.features.cli.claude-code = {
    enable = mkEnableOption "Claude Code CLI tool";
    enableNotifications = mkOption {
      type = types.bool;
      default = true;
      description = "Enable desktop notifications via notify-send";
    };
    enableHooks = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Claude Code hooks configuration";
    };
  };

  config = mkIf cfg.enable (let
    # Create permission hook script in Nix store from separate file
    permissionHookScript =
      pkgs.writeShellScript "claude-permission-hook"
      (builtins.readFile (pkgs.replaceVars ./hooks/claude-permission-hook.sh {
        jq = "${pkgs.jq}/bin/jq";
        notifysend = "${pkgs.libnotify}/bin/notify-send";
        zenity = "${pkgs.zenity}/bin/zenity";
      }));
  in {
    # Install Claude Code package
    home.packages = with pkgs;
      [
        (unstable.claude-code.overrideAttrs (oldAttrs: {
          version = claudeCodeVersion;
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claudeCodeVersion}.tgz";
            sha256 = "sha256-ypS7TV0eOqzLAQMz2z8KHRzI1OcCv4ai5gSenM2RoSc=";
          };
        }))
      ]
      ++ optionals cfg.enableNotifications [
        libnotify
        zenity
        imagemagick
        curl
      ];

    programs.zsh = {
      # From https://github.com/anthropics/claude-code/issues/2110#issuecomment-2996564886
      envExtra = ''
        if command -v direnv >/dev/null; then
          if [[ ! -z "$CLAUDECODE" ]]; then
            eval "$(direnv hook zsh)"
            eval "$(DIRENV_LOG_FORMAT= direnv export zsh)"  # Need to trigger "hook" manually

            # If the .envrc is not allowed, allow it
            direnv status --json | jq -e ".state.foundRC.allowed==0" >/dev/null || direnv allow >/dev/null 2>&1
          fi
        fi
      '';
    };

    # Create notification hook scripts
    home.file.".claude/hooks/notification.sh" = mkIf (cfg.enableHooks && cfg.enableNotifications) {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Read input and extract message
        input=$(cat)
        message=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.message // "Claude Code notification"')

        # Send notification
        ${pkgs.libnotify}/bin/notify-send 'Claude Code' "$message" --icon=dialog-information --urgency=normal
      '';
    };

    # Old pretooluse.sh script removed - now using external permission-notify.sh script

    # Setup Claude icon for dialogs
    home.activation.setupClaudeIcon = mkIf cfg.enableNotifications (lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.dotfiles/home/features/cli/hooks/setup-claude-icon.sh
    '');

    # Create Claude Code hooks configuration
    home.file.".claude/settings.json" = mkIf cfg.enableHooks {
      text = builtins.toJSON {
        hooks = optionalAttrs cfg.enableNotifications {
          Notification = [
            {
              matcher = "*";
              hooks = [
                {
                  type = "command";
                  command = "$HOME/.claude/hooks/notification.sh";
                }
              ];
            }
          ];
          PreToolUse = [
            {
              matcher = "*";
              hooks = [
                {
                  type = "command";
                  command = "${permissionHookScript}";
                  timeout = 30000;
                }
              ];
            }
          ];
        };
      };
    };
  });
}
