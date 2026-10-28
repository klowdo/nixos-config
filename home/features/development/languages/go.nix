{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.languages.go;
in {
  options.features.development.languages.go = {
    enable = mkEnableOption "enable go toolchain";
    privateModules = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["github.com/volvo-cars/*"];
    };
  };
  config = mkIf cfg.enable {
    programs.go = {
      enable = true;
      env.GOPRIVATE = cfg.privateModules;
    };
  };
}
