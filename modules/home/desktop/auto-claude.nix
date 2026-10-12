{...}: {
  flake.modules.homeManager.auto-claude = {
    config,
    lib,
    pkgs,
    ...
  }: let
    auto-claude-wrapped = pkgs.writeShellScriptBin "auto-claude" ''
      export CLAUDE_CONFIG_DIR="${config.xdg.configHome}/auto-claude"
      export CLAUDE_CODE_OAUTH_TOKEN="$(cat ${config.sops.secrets."claude/oauth-token".path})"
      exec ${pkgs.auto-claude-appimage}/bin/auto-claude "$@"
    '';
  in {
    home.packages = [
      auto-claude-wrapped
    ];

    xdg.desktopEntries.auto-claude = {
      name = "Auto-Claude";
      genericName = "AI Coding Assistant";
      comment = "Autonomous multi-agent coding framework powered by Claude AI";
      exec = "${auto-claude-wrapped}/bin/auto-claude %U";
      icon = "${pkgs.auto-claude-appimage}/share/pixmaps/auto-claude.png";
      terminal = false;
      type = "Application";
      categories = ["Development" "Utility"];
    };

    services.ollama = {
      enable = true;
      package = pkgs.ollama-cpu;
    };

    specialisation = {
      nvidia.configuration = {
        services.ollama = {
          package = lib.mkDefault pkgs.ollama-cuda;
          acceleration = lib.mkDefault "cuda";
        };
      };
    };
  };
}
