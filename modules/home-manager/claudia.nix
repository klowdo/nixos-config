{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.claudia;
in {
  options.programs.claudia = {
    enable = mkEnableOption "Claudia - Claude desktop app";

    package = mkOption {
      type = types.package;
      default = pkgs.claudia;
      defaultText = literalExpression "pkgs.claudia";
      description = "The Claudia package to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}