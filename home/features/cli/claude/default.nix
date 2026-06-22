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

      scanSecretsHookScript = pkgs.writeShellScript "scan-secrets-hook" (
        builtins.replaceStrings
        ["@jq@" "@grep@"]
        ["${pkgs.jq}/bin/jq" "${pkgs.gnugrep}/bin/grep"]
        (builtins.readFile ./hooks/scan-secrets-hook.sh)
      );

      sessionContextHookScript = pkgs.writeShellScript "session-context-hook" (
        builtins.replaceStrings
        ["@jq@" "@git@"]
        ["${pkgs.jq}/bin/jq" "${pkgs.git}/bin/git"]
        (builtins.readFile ./hooks/session-context-hook.sh)
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

      # sops.secrets."claude/oauth-token" = {
      #   sopsFile = ../../../../secrets.yaml;
      #   mode = "0600";
      #   path = ".claude/.credentials.json";
      # };

      home = {
        packages =
          [pkgs.unstable.rtk pkgs.jq pkgs.codegraph]
          ++ (with pkgs;
            optionals cfg.enableNotifications [
              libnotify
            ]);
        file.".claude/RTK.md".source = ./RTK.md;
        shellAliases = {
          cl = "claude --permission-mode bypassPermissions ";
        };
      };

      programs.claude-code = {
        enable = true;
        package = claudeCodePackage;

        context = ./CLAUDE.md;
        agentsDir = ./agents;
        commandsDir = ./commands;
        skills = ./skills;

        # lspServers requires home-manager newer than current 2026-04-05 pin.
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
          codegraph = {
            type = "stdio";
            command = "${pkgs.codegraph}/bin/codegraph";
            args = ["serve" "--mcp"];
            env = {
              CODEGRAPH_MCP_TOOLS = "explore,search,node,callers,callees,impact";
              DO_NOT_TRACK = "1";
            };
          };
        };

        # Settings reference: https://code.claude.com/docs/en/settings
        settings = {
          # model = "claude-opus-4-6[1M]";
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
            allow = [
              "mcp__codegraph__codegraph_explore"
              "mcp__codegraph__codegraph_search"
              "mcp__codegraph__codegraph_node"
              "mcp__codegraph__codegraph_callers"
              "mcp__codegraph__codegraph_callees"
              "mcp__codegraph__codegraph_impact"
              "Bash(git status*)"
              "Bash(git diff*)"
              "Bash(git log*)"
              "Bash(git branch*)"
              "Bash(git show*)"
              "Bash(git rev-parse*)"
              "Bash(git remote*)"
              "Bash(ls*)"
              "Bash(find*)"
              "Bash(grep*)"
              "Bash(cat*)"
              "Bash(head*)"
              "Bash(tail*)"
              "Bash(wc*)"
              "Bash(which*)"
              "Bash(echo*)"
              "Bash(pwd*)"
              "Bash(hostname*)"
              "Bash(nix eval*)"
              "Bash(nix flake metadata*)"
              "Bash(nix flake show*)"
              "Bash(nh os test*)"
            ];
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
            "caveman@caveman" = false;
            "ponytail@ponytail" = true;
            "claude-mem@thedotmack" = false;
          };
          extraKnownMarketplaces = {
            caveman = {
              source = {
                source = "github";
                repo = "JuliusBrussee/caveman";
              };
            };
            ponytail = {
              source = {
                source = "github";
                repo = "DietrichGebert/ponytail";
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
            ENABLE_LSP_TOOL = "1";
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
            SessionStart = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "${sessionContextHookScript}";
                    statusMessage = "Loading project context...";
                  }
                ];
              }
            ];
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
            PostToolUse =
              [
                {
                  matcher = "Write|Edit|MultiEdit";
                  hooks = [
                    {
                      type = "command";
                      command = "${scanSecretsHookScript}";
                      asyncRewake = true;
                    }
                  ];
                }
              ]
              ++ (
                lib.optionals cfg.enableNotifications [
                  {
                    matcher = "*";
                    hooks = [
                      {
                        type = "command";
                        command = "${notificationHookScript}";
                      }
                    ];
                  }
                ]
              );
          };
        };
      };
    }
  );
}
