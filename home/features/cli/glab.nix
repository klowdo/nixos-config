{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.gitlab-cli;
in {
  options.features.cli.gitlab-cli.enable = mkEnableOption "gitlab cli management";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.glab];
  };
}
