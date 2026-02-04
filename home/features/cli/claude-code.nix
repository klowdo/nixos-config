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

  config = mkIf cfg.enable (
    let
      claudeCodePackage = pkgs.claude-code;

      notificationHookScript = pkgs.writeShellScript "claude-notification-hook" (
        pkgs.replaceVars ./hooks/claude-notification-hook.sh {
          jq = "${pkgs.jq}/bin/jq";
          notifysend = "${pkgs.libnotify}/bin/notify-send";
        }
      );
    in {
      programs.zsh = {
        envExtra = ''
          if command -v direnv >/dev/null; then
            if [[ ! -z "$CLAUDECODE" ]]; then
              eval "$(direnv hook zsh)"
              eval "$(DIRENV_LOG_FORMAT= direnv export zsh)"

              direnv status --json | jq -e ".state.foundRC.allowed==0" >/dev/null || direnv allow >/dev/null 2>&1
            fi
          fi
        '';
      };

      sops.secrets."claude/oauth-token" = {
        sopsFile = ../../../secrets.yaml;
        mode = "0600";
        path = ".claude/.credentials.json";
      };

      home.packages = with pkgs;
        optionals cfg.enableNotifications [
          libnotify
          jq
        ];

      programs.claude-code = {
        enable = true;
        package = claudeCodePackage;

        memory.source = ./claude/CLAUDE.md;
        agentsDir = ./claude/agents;
        commandsDir = ./claude/commands;

        mcpServers = {
          nixos = {
            command = "nix";
            args = ["run" "github:utensils/mcp-nixos" "--"];
          };
        };

        settings = {
          includeCoAuthoredBy = false;
          env = {
            CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR = "1";
          };
          statusLine = {
            type = "command";
            command = ./claude/status-line.sh;
            padding = 0;
          };
          attribution = {
            commit = "";
            pr = "";
          };
          hooks = mkIf cfg.enableNotifications {
            PostToolUse = [
              {
                matcher = "*";
                hooks = [
                  {
                    type = "command";
                    command = "${notificationHookScript}";
                  }
                ];
              }
            ];
          };
        };
      };
    }
  );
}
