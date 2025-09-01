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

    # Claude Code package
    claudeCodePackage = pkgs.unstable.claude-code.overrideAttrs (oldAttrs: {
      version = claudeCodeVersion;
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claudeCodeVersion}.tgz";
        sha256 = "sha256-ypS7TV0eOqzLAQMz2z8KHRzI1OcCv4ai5gSenM2RoSc=";
      };
    });
  in {
    # Install Claude Code package

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
          (pkgs.writeShellScriptBin "claude" ''
            SHELL=${pkgs.bash}/bin/bash exec ${claudeCodePackage}/bin/claude "$@"
          '')
        ]
        ++ optionals cfg.enableNotifications [
          libnotify
          zenity
          imagemagick
          curl
        ];

      file =
        {
          ".claude/agents/meta-agent.md"  .source = ./claude/agents/meta-agent.md;
          ".claude/commands/git_status.md"  .source = ./claude/commands/git_status.md;
          ".claude/mcp_servers.json".source = ./claude/mcp_servers.json;
        }
        // (optionalAttrs (cfg.enableHooks && cfg.enableNotifications) {
          ".claude/hooks/notification.sh" = {
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
        })
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
              # "permissions" = {
              #   "defaultMode" = "bypassPermissions";
              # };
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
    };

    # Create notification hook scripts and symlink claude files

    # Setup Claude icon for dialogs
    home.activation.setupClaudeIcon = mkIf cfg.enableNotifications (lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.dotfiles/home/features/cli/hooks/setup-claude-icon.sh
    '');
  });
}
