{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.junie;

  junieWrapped = pkgs.writeShellScriptBin "junie" ''
    ${optionalString (cfg.apiKeySecretPath != null) ''
      export JUNIE_API_KEY="$(cat ${cfg.apiKeySecretPath})"
    ''}
    ${optionalString (cfg.anthropicApiKeySecretPath != null) ''
      export JUNIE_ANTHROPIC_API_KEY="$(cat ${cfg.anthropicApiKeySecretPath})"
    ''}
    exec ${cfg.package}/bin/junie "$@"
  '';

  hasSecrets = cfg.apiKeySecretPath != null || cfg.anthropicApiKeySecretPath != null;

  junieConfig = builtins.toJSON ({auto-update = false;} // cfg.settings);
in {
  options.programs.junie = {
    enable = mkEnableOption "Junie - JetBrains AI coding agent CLI";

    package = mkOption {
      type = types.package;
      default = pkgs.junie;
      defaultText = literalExpression "pkgs.junie";
      description = "The Junie package to install.";
    };

    apiKeySecretPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing the JUNIE_API_KEY.";
    };

    anthropicApiKeySecretPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing the JUNIE_ANTHROPIC_API_KEY.";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional settings merged into ~/.junie/config.json.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (
        if hasSecrets
        then junieWrapped
        else cfg.package
      )
    ];

    home.file.".junie/config.json".text = junieConfig;
  };
}
