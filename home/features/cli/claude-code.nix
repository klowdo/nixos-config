{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.claude-code;
  claudeCodeVersion = "1.0.60";
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

  config = mkIf cfg.enable {
    # Install Claude Code package
    home.packages = with pkgs;
      [
        (unstable.claude-code.overrideAttrs (oldAttrs: {
          version = claudeCodeVersion;
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claudeCodeVersion}.tgz";
            sha256 = "sha256-I5+LUI3VbDVc0G3iYT1EhYkFrp9cM3sSyhjXHNwCUgM=";
          };
        }))
      ]
      ++ optionals cfg.enableNotifications [
        libnotify
        zenity
      ];

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

    home.file.".claude/hooks/pretooluse.sh" = mkIf (cfg.enableHooks && cfg.enableNotifications) {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Read input
        input=$(cat)
        tool_name=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.tool_name // "Unknown tool"')

        # Send notification about tool usage
        ${pkgs.libnotify}/bin/notify-send 'Claude Code' "Using tool: $tool_name" --icon=dialog-question --urgency=normal

        # Always allow the tool to proceed
        echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}'
      '';
    };

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
                  command = "${config.home.homeDirectory}/.dotfiles/home/features/cli/hooks/permission-notify.sh";
                  timeout = 30000;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
