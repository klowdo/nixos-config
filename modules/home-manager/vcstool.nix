{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.vcstool;
  format = pkgs.formats.yaml {};

  repoType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum ["git" "hg" "svn" "bzr"];
        default = "git";
        description = "VCS type";
      };

      url = mkOption {
        type = types.str;
        description = "Repository URL";
      };

      version = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Branch, tag, or commit to checkout";
      };
    };
  };

  workspaceType = types.submodule {
    options = {
      root = mkOption {
        type = types.str;
        description = "Root directory for this workspace";
        example = "~/projects";
      };

      repos = mkOption {
        type = types.attrsOf repoType;
        default = {};
        description = "Repositories in this workspace (key is relative path)";
      };
    };
  };

  workspaceConfigData = workspace: {
    repositories = mapAttrs (name: repo:
      {
        inherit (repo) type url;
      }
      // optionalAttrs (repo.version != null) {inherit (repo) version;})
    workspace.repos;
  };

  syncScript = pkgs.writeShellScriptBin "vcs-sync" ''
    set -euo pipefail
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"

    ${concatStringsSep "\n" (imap0 (i: workspace: let
        inherit (workspace) root;
        configFile = "$XDG_CONFIG_HOME/vcstool/workspace-${toString i}.yaml";
      in ''
        echo "Syncing workspace: ${root}"
        mkdir -p "${root}"
        ${cfg.package}/bin/vcs import --skip-existing "${root}" < "${configFile}"
      '')
      cfg.workspaces)}
  '';

  workspaceConfigs = listToAttrs (imap0 (i: workspace: {
      name = "vcstool/workspace-${toString i}.yaml";
      value = {
        source = format.generate "workspace-${toString i}.yaml" (workspaceConfigData workspace);
      };
    })
    cfg.workspaces);
in {
  options.programs.vcstool = {
    enable = mkEnableOption "vcstool - version control system tool for multiple repositories";

    package = mkOption {
      type = types.package;
      default = pkgs.vcstool;
      defaultText = literalExpression "pkgs.vcstool";
      description = "The vcstool package to use";
    };

    workspaces = mkOption {
      type = types.listOf workspaceType;
      default = [];
      description = "Workspaces containing repositories to manage";
      example = literalExpression ''
        [
          {
            root = "~/projects";
            repos = {
              "my-project" = {
                url = "git@github.com:user/my-project.git";
                version = "main";
              };
              "another/nested" = {
                url = "git@github.com:user/another.git";
              };
            };
          }
        ]
      '';
    };

    service = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable systemd user service for repository sync";
      };

      onCalendar = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Systemd calendar expression for periodic sync";
        example = "daily";
      };

      onActivation = mkOption {
        type = types.bool;
        default = false;
        description = "Run sync during home-manager activation";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package syncScript];

    xdg.configFile = workspaceConfigs;

    home.activation.vcs-sync = mkIf cfg.service.onActivation (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        PATH="${lib.makeBinPath [cfg.package pkgs.git pkgs.openssh pkgs.coreutils]}:$PATH"
        run --quiet ${syncScript}/bin/vcs-sync || true
      ''
    );

    systemd.user.services.vcs-sync = mkIf cfg.service.enable {
      Unit = {
        Description = "VCS Tool sync";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${syncScript}/bin/vcs-sync";
        Environment = [
          "PATH=${lib.makeBinPath [cfg.package pkgs.git pkgs.openssh pkgs.coreutils]}"
        ];
      };
    };

    systemd.user.timers.vcs-sync = mkIf (cfg.service.enable && cfg.service.onCalendar != null) {
      Unit.Description = "VCS Tool periodic sync";
      Timer = {
        OnCalendar = cfg.service.onCalendar;
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
