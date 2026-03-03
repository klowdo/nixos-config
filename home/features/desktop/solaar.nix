{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.solaar;

  toYamlValue = v:
    if isList v
    then "[${concatMapStringsSep ", " toYamlValue v}]"
    else if isInt v
    then toString v
    else v;

  renderEntry = entry: let
    key = head (attrNames entry);
    val = entry.${key};
  in "${key}: ${toYamlValue val}";

  renderRule = rule:
    concatStringsSep "\n" (
      ["---"] ++ map (e: "- ${renderEntry e}") rule ++ ["..."]
    );

  rulesText = concatStringsSep "\n" (
    ["%YAML 1.3"] ++ map renderRule cfg.rules
  );
in {
  options.features.desktop.solaar = {
    enable = mkEnableOption "Solaar rule engine for Logitech devices";

    rules = mkOption {
      type = with types;
        listOf (listOf (attrsOf anything));
      default = [];
      description = "List of Solaar rules. Each rule is a list of condition/action attrsets.";
    };
  };

  config = mkIf (cfg.enable && cfg.rules != []) {
    xdg.configFile."solaar/rules.yaml".text = rulesText;
  };
}
