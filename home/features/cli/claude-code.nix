{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.cli.claude-code;

  # Import plugins configuration
  pluginsConfig = import ./claude/plugins {inherit lib inputs;};

  # Skills configuration from various sources (paths to directories)
  skillsFromInputs =
    lib.optionalAttrs (inputs ? claude-skills) {
      # Skills from claude-skills marketplace (directory)
      claude-skills = inputs.claude-skills;
    }
    // lib.optionalAttrs (inputs ? anthropic-skills) {
      # Skills from Anthropic (directory)
      anthropic-skills = inputs.anthropic-skills;
    }
    // lib.optionalAttrs (inputs ? superpowers-marketplace) {
      # Skills from superpowers marketplace (directory)
      superpowers = inputs.superpowers-marketplace;
    };
in {
  options.features.cli.claude-code = {
    enable = mkEnableOption "Claude Code CLI tool";
    enableNotifications = mkOption {
      type = types.bool;
      default = true;
      description = "Enable desktop notifications via notify-send";
    };
    enablePlugins = mkOption {
      type = types.bool;
      default = true;
      description = "Enable plugin marketplace integration";
    };
    enableCookbookSkills = mkOption {
      type = types.bool;
      default = true;
      description = "Enable skills/commands from claude-cookbooks";
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

      # Generate marketplace registry JSON
      marketplacesJson = builtins.toJSON {
        version = "1.0";
        marketplaces = lib.mapAttrs (name: mp: {
          inherit name;
          inherit (mp) description;
          source = mp.source;
        }) pluginsConfig.marketplaces;
      };

      # Cookbook commands (if available) - paths to .md files
      cookbookCommands = lib.optionalAttrs (cfg.enableCookbookSkills && inputs ? claude-cookbooks) {
        review-issue = "${inputs.claude-cookbooks}/claude-code/commands/review-issue.md";
        notebook-review = "${inputs.claude-cookbooks}/claude-code/commands/notebook-review.md";
        model-check = "${inputs.claude-cookbooks}/claude-code/commands/model-check.md";
      };

      # Cookbook agents (if available) - paths to .md files
      cookbookAgents = lib.optionalAttrs (cfg.enableCookbookSkills && inputs ? claude-cookbooks) {
        code-reviewer = "${inputs.claude-cookbooks}/claude-code/agents/code-reviewer.md";
      };

      # Local commands
      localCommands = {
        git_status = ./claude/commands/git_status.md;
      };

      # Local agents
      localAgents = {
        meta-agent = ./claude/agents/meta-agent.md;
      };
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

      # Marketplace registry file
      home.file = lib.mkIf cfg.enablePlugins {
        ".claude/plugins/known_marketplaces.json" = {
          text = marketplacesJson;
        };
      };

      programs.claude-code = {
        enable = true;
        package = claudeCodePackage;

        memory.source = ./claude/CLAUDE.md;

        # Agents: local + cookbook
        agents = localAgents // cookbookAgents;

        # Commands: local + cookbook
        commands = localCommands // cookbookCommands;

        # Skills from various marketplaces
        skills = lib.mkIf cfg.enableCookbookSkills skillsFromInputs;

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
