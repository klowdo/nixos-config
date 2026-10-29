{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.codex;

  herdrIntegration = pkgs.runCommand "herdr-codex-integration" {} ''
    mkdir -p $out/.codex
    HOME=$out ${pkgs.unstable.herdr}/bin/herdr integration install codex
  '';
in {
  options.features.development.codex.enable = mkEnableOption "enable OpenAI Codex CLI";

  config = mkIf cfg.enable {
    programs.codex = {
      enable = true;
      package = pkgs.unstable.codex;
      settings.features.hooks = true;
      context = ''
        Never mention Codex, OpenAI or any AI assistant in commit messages, PR descriptions or code.
      '';
    };

    home.file.".codex/hooks.json" = mkIf config.features.cli.herdr.enable {
      text = builtins.toJSON {
        hooks.SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "bash '${herdrIntegration}/.codex/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ];
          }
        ];
      };
      force = true;
    };
  };
}
