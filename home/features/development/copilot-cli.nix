{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.copilot-cli;
in {
  options.features.development.copilot-cli.enable = mkEnableOption "enable GitHub Copilot CLI";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.github-copilot-cli];
  };
}
