{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.nh;
in {
  options.features.cli.nh.enable = mkEnableOption "enable nh cli tool";

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = "/home/klowdo/.dotfiles/";
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };
}
