{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.copilot-cli;

  herdrIntegration = pkgs.runCommand "herdr-copilot-integration" {} ''
    mkdir -p $out/.copilot
    HOME=$out ${pkgs.unstable.herdr}/bin/herdr integration install copilot
  '';

  herdrHooks = optionalAttrs config.features.cli.herdr.enable {
    SessionStart = [
      {
        type = "command";
        bash = "bash '${herdrIntegration}/.copilot/hooks/herdr-agent-state.sh'";
        timeoutSec = 10;
      }
    ];
  };
in {
  options.features.development.copilot-cli.enable = mkEnableOption "enable GitHub Copilot CLI";

  config = mkIf cfg.enable {
    programs.github-copilot-cli = {
      enable = true;
      package = pkgs.unstable.github-copilot-cli.overrideAttrs (old: {
        postInstall =
          replaceStrings ["--add-flag --no-auto-update"]
          ["--add-flag --no-auto-update --argv0 copilot --suffix PATH : ${pkgs.python3}/bin"]
          old.postInstall;
      });
      context = ''
        Never mention Copilot, GitHub Copilot or any AI assistant in commit messages, PR descriptions or code.
      '';
    };

    home.file.".copilot/settings.json" = {
      text = builtins.toJSON {
        includeCoAuthoredBy = false;
        hooks = herdrHooks;
      };
      force = true;
    };
  };
}
