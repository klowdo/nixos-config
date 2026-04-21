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
      claudeCodePackage = pkgs.symlinkJoin {
        name = "claude-code-wrapped";
        paths = [pkgs.claude-code];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/claude \
            --prefix FORCE_HYPERLINK : 1 \
            --prefix PATH : ${lib.makeBinPath [pkgs.nodejs_22 pkgs.bun]}
        '';
      };

      notificationHookScript = pkgs.writeShellScript "claude-notification-hook" ''
        exec ${pkgs.bash}/bin/bash ${pkgs.replaceVars ./hooks/claude-notification-hook.sh {
          jq = "${pkgs.jq}/bin/jq";
          notifysend = "${pkgs.libnotify}/bin/notify-send";
          logo = "${./logo.png}";
        }} "$@"
      '';

      rtkRewriteHookContent =
        builtins.replaceStrings
        ["@jq@" "@rtk@"]
        ["${pkgs.jq}/bin/jq" "${pkgs.unstable.rtk}/bin/rtk"]
        (builtins.readFile ./hooks/rtk-rewrite-hook.sh);
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

      # sops.secrets."claude/oauth-token" = {
      #   sopsFile = ../../../../secrets.yaml;
      #   mode = "0600";
      #   path = ".claude/.credentials.json";
      # };

      home = {
        packages =
          [pkgs.unstable.rtk]
          ++ (with pkgs;
            optionals cfg.enableNotifications [
              libnotify
              jq
            ]);
        file.".claude/RTK.md".source = ./RTK.md;
        shellAliases = {
          cl = "claude --permission-mode bypassPermissions ";
        };
      };

      programs.claude-code = {
        enable = true;
        package = claudeCodePackage;

        memory.source = ./CLAUDE.md;
        agentsDir = ./agents;
        commandsDir = ./commands;
        skillsDir = ./skills;

        # lspServers requires home-manager newer than 2026-04-05 pin.
        # Once HM is bumped, drop gopls-lsp@claude-plugins-official from
        # enabledPlugins and uncomment this block.
        # lspServers.go = {
        #   command = "${pkgs.gopls}/bin/gopls";
        #   args = ["serve"];
        #   extensionToLanguage.".go" = "go";
        # };

        hooks."rtk-rewrite.sh" = rtkRewriteHookContent;

        mcpServers = {
          nixos = {
            command = "nix";
            args = ["run" "github:utensils/mcp-nixos" "--"];
          };
          tokennuke = {
            command = "${pkgs.tokennuke}/bin/tokennuke";
          };
        };

        # Settings reference: https://code.claude.com/docs/en/settings
        settings = {
          editorMode = "vim";
          theme = "dark-ansi";
          effortLevel = "medium";
          includeCoAuthoredBy = false;
          skipDangerousModePermissionPrompt = true;
          showThinkingSummaries = true;
          tui = "fullscreen";
          cleanupPeriodDays = 14;
          spinnerTipsEnabled = false;
          permissions = {
            deny = [
              "Bash(sops:*)"
              "Bash(rtk proxy sops:*)"
              "Bash(just sops-get:*)"
              "Bash(just sops-edit:*)"
              "Bash(just sops-updatekeys:*)"
              "Bash(age:*)"
              "Bash(rtk proxy age:*)"
              "Read(/run/secrets/**)"
              "Read(/run/secrets.d/**)"
              "Read(//home/klowdo/.dotfiles/secrets/**)"
              "Read(//home/klowdo/.config/sops/**)"
              "Read(//home/klowdo/.config/sops-nix/**)"
            ];
          };
          enabledPlugins = {
            "claude-code-wakatime@wakatime" = true;
            "frontend-design@claude-plugins-official" = true;
            "context7@claude-plugins-official" = true;
            "code-review@claude-plugins-official" = false;
            "gopls-lsp@claude-plugins-official" = true;
            "superpowers@superpowers-marketplace" = true;
            "code-simplifier@claude-plugins-official" = true;
            "worktrunk@worktrunk" = true;
            "caveman@caveman" = true;
            "claude-mem@thedotmack" = true;
          };
          extraKnownMarketplaces = {
            caveman = {
              source = {
                source = "github";
                repo = "JuliusBrussee/caveman";
              };
            };
            claude-plugins-official = {
              source = {
                source = "github";
                repo = "anthropics/claude-plugins-official";
              };
            };
            wakatime = {
              source = {
                source = "git";
                url = "https://github.com/wakatime/claude-code-wakatime.git";
              };
            };
            worktrunk = {
              source = {
                source = "github";
                repo = "max-sixty/worktrunk";
              };
            };
            superpowers-marketplace = {
              source = {
                source = "github";
                repo = "obra/superpowers-marketplace";
              };
            };
            thedotmack = {
              source = {
                source = "github";
                repo = "thedotmack/claude-mem";
              };
            };
          };
          env = {
            CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR = "1";
          };
          statusLine = {
            type = "command";
            command = ./status-line.sh;
            padding = 0;
          };
          attribution = {
            commit = "";
            pr = "";
          };
          hooks = {
            PreToolUse = [
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.claude/hooks/rtk-rewrite.sh";
                  }
                ];
              }
            ];
            PostToolUse = mkIf cfg.enableNotifications [
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
