{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.junie = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.features.development.tools.junie;
    in {
      imports = [flake.modules.homeManager.sops];

      options.features.development.tools.junie = {
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

      config = {
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
    };
}
