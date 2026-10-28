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
      package = pkgs.symlinkJoin {
        name = "github-copilot-cli";
        paths = [pkgs.unstable.github-copilot-cli];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = "wrapProgram $out/bin/copilot --suffix PATH : ${pkgs.python3}/bin";
      };
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
