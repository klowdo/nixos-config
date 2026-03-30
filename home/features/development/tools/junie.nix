{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.tools.junie;
in {
  options.features.development.tools.junie = {
    enable = mkEnableOption "junie AI coding agent";

    apiKeySecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SOPS secret key for JUNIE_API_KEY";
    };

    anthropicApiKeySecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SOPS secret key for JUNIE_ANTHROPIC_API_KEY";
    };
  };

  config = mkIf cfg.enable {
    programs.junie = {
      enable = true;
      apiKeySecretPath =
        mkIf (cfg.apiKeySecret != null)
        config.sops.secrets.${cfg.apiKeySecret}.path;
      anthropicApiKeySecretPath =
        mkIf (cfg.anthropicApiKeySecret != null)
        config.sops.secrets.${cfg.anthropicApiKeySecret}.path;
    };
  };
}
