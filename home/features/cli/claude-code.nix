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
    # Claude Code package
    claudeCodePackage = pkgs.unstable.claude-code.overrideAttrs (oldAttrs: {
      version = claudeCodeVersion;
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claudeCodeVersion}.tgz";
        sha256 = "sha256-ypS7TV0eOqzLAQMz2z8KHRzI1OcCv4ai5gSenM2RoSc=";
      };
    });

    # Permission hook script with proper substitutions
    permissionHookScript = pkgs.writeShellScript "claude-permission-hook"
      (builtins.readFile (pkgs.replaceVars ./hooks/claude-permission-hook.sh {
        jq = "${pkgs.jq}/bin/jq";
        zenity = "${pkgs.zenity}/bin/zenity";
        notifysend = "${pkgs.libnotify}/bin/notify-send";
      }));

    # Post-operation notification hook script with proper substitutions
    notificationHookScript = pkgs.writeShellScript "claude-notification-hook"
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
        ++ optionals cfg.enableHooks [
          # Required packages for hooks
          libnotify  # For desktop notifications
          zenity     # For permission dialogs
          jq         # For JSON parsing in hooks
          
          # Permission management helper script
          (pkgs.writeShellScriptBin "claude-permissions"
            (builtins.readFile (pkgs.replaceVars ./hooks/claude-permissions.sh {
              notifysend = "${libnotify}/bin/notify-send";
            })))
        ];

      file =
        {
          ".claude/agents/meta-agent.md".source = ./claude/agents/meta-agent.md;
          ".claude/commands/git_status.md".source = ./claude/commands/git_status.md;
          ".claude/mcp_servers.json".source = ./claude/mcp_servers.json;
        }
        // (optionalAttrs cfg.enableHooks {
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
              "hooks" = [
                {
                  "name" = "permission_hook";
                  "description" = "Interactive permission confirmation for file operations";
                  "hookEventName" = "PreToolUse";
                  "command" = "${permissionHookScript}";
                  "toolMatchers" = [
                    {
                      "toolName" = "Write";
                    }
                    {
                      "toolName" = "Edit";
                    }
                    {
                      "toolName" = "MultiEdit";
                    }
                    {
                      "toolName" = "Bash";
                      "toolInputMatchers" = [
                        {
                          "jsonPath" = "$.command";
                          "regex" = ".*(rm -rf|dd if=|mkfs|> /dev/|sudo).*";
                        }
                      ];
                    }
                  ];
                }
              ] ++ optionals cfg.enableNotifications [
                {
                  "name" = "notification_hook";
                  "description" = "Desktop notifications for completed operations";
                  "hookEventName" = "PostToolUse";
                  "command" = "${notificationHookScript}";
                  "toolMatchers" = [
                    {
                      "toolName" = "Write";
                    }
                    {
                      "toolName" = "Edit";
                    }
                    {
                      "toolName" = "MultiEdit";
                    }
                    {
                      "toolName" = "Bash";
                      "toolInputMatchers" = [
                        {
                          "jsonPath" = "$.command";
                          "regex" = ".*(git|just rebuild|nixos-rebuild|nix build|home-manager).*";
                        }
                      ];
                    }
                  ];
                }
              ];
            };
          };
        })
        // (optionalAttrs (!cfg.enableHooks) {
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
