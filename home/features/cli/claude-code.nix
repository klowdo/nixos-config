{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.claude-code;
in {
  options.features.cli.claude-code = {
    enable = mkEnableOption "Claude Code CLI tool";
    enableNotifications = mkOption {
      type = types.bool;
      default = true;
      description = "Enable desktop notifications via notify-send";
    };
  };

  config = mkIf cfg.enable (let
    # Claude Code package (Bun variant for faster performance)
    # From sadjow/claude-code-nix flake - auto-updates within 1 hour of release
    claudeCodePackage = pkgs.claude-code;
    #
    # Post-operation notification hook script with proper substitutions
    notificationHookScript =
      pkgs.writeShellScript "claude-notification-hook"
      (builtins.readFile (pkgs.replaceVars ./hooks/claude-notification-hook.sh {
        jq = "${pkgs.jq}/bin/jq";
        notifysend = "${pkgs.libnotify}/bin/notify-send";
      }));
  in {
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

    home = {
      packages = with pkgs;
        [
          (writeShellScriptBin "claude" ''
            SHELL=${bash}/bin/bash exec ${claudeCodePackage}/bin/claude "$@"
          '')
        ]
        ++ optionals cfg.enableNotifications [
          # Required packages for notifications
          libnotify # For desktop notifications
          jq # For JSON parsing in hooks
        ];

      file =
        {
          ".claude/agents/meta-agent.md".source = ./claude/agents/meta-agent.md;
          ".claude/commands/git_status.md".source = ./claude/commands/git_status.md;
          ".claude/mcp_servers.json".source = ./claude/mcp_servers.json;
        }
        // (optionalAttrs cfg.enableNotifications {
          ".claude/settings.json" = {
            text = builtins.toJSON {
              "includeCoAuthoredBy" = false;
              "env" = {
                "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR" = "1";
              };
              "statusLine" = {
                "type" = "command";
                "command" = ./claude/status-line.sh;
                "padding" = 0;
              };
              "hooks" = {
                "PostToolUse" = [
                  {
                    "matcher" = "*";
                    "hooks" = [
                      {
                        "type" = "command";
                        "command" = "${notificationHookScript}";
                      }
                    ];
                  }
                ];
              };
            };
          };
        })
        // (optionalAttrs (!cfg.enableNotifications) {
          ".claude/settings.json" = {
            text = builtins.toJSON {
              "includeCoAuthoredBy" = false;
              "env" = {
                "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR" = "1";
              };
              "statusLine" = {
                "type" = "command";
                "command" = ./claude/status-line.sh;
                "padding" = 0;
              };
            };
          };
        });
    };
  });
}
