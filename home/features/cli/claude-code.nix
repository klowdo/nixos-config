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

  # Import skills configuration
  skillsConfig = import ./claude/skills {inherit lib inputs;};

  # Helper to copy cookbook files to .claude directory
  mkCookbookFiles = skills:
    lib.mapAttrs' (name: skill:
      lib.nameValuePair ".claude/commands/${name}.md" {
        source = skill.sourcePath;
      })
    skills;

  mkCookbookAgents = agents:
    lib.mapAttrs' (name: agent:
      lib.nameValuePair ".claude/agents/${name}.md" {
        source = agent.sourcePath;
      })
    agents;
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

      # Copy cookbook commands and agents to .claude directory
      home.file = lib.mkMerge [
        # Cookbook commands (if enabled and inputs available)
        (lib.mkIf (cfg.enableCookbookSkills && inputs ? claude-cookbooks)
          (mkCookbookFiles skillsConfig.commands))

        # Cookbook agents (if enabled and inputs available)
        (lib.mkIf (cfg.enableCookbookSkills && inputs ? claude-cookbooks)
          (mkCookbookAgents skillsConfig.agents))

        # Marketplace registry
        (lib.mkIf cfg.enablePlugins {
          ".claude/plugins/known_marketplaces.json" = {
            text = marketplacesJson;
          };
        })
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
