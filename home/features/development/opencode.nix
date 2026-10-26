{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.opencode;
  secretFile = name: "{file:${config.sops.secrets.${name}.path}}";
in {
  options.features.development.opencode = {
    enable = mkEnableOption "enable opencode AI coding agent";

    apiKeySecrets = mkOption {
      type = types.attrsOf types.str;
      default = {anthropic = "applications/opencode/anthropic-api-key";};
      description = "Provider id to sops secret name holding its API key";
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default model id, e.g. github-copilot/claude-sonnet-4.5";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = mapAttrs' (_: name: nameValuePair name {mode = "0400";}) cfg.apiKeySecrets;

    programs.opencode = {
      enable = true;
      package = pkgs.unsafe.opencode;
      settings = {
        provider = mapAttrs (_: name: {options.apiKey = secretFile name;}) cfg.apiKeySecrets;
        model = mkIf (cfg.model != null) cfg.model;
      };
    };
  };
}
