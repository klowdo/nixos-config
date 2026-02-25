{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.taskwarrior;
in {
  options.features.cli.taskwarrior.enable = mkEnableOption "enable task warrior";

  config = mkIf cfg.enable {
    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
    };
    home.packages = with pkgs; [
      # syncall
      vit
      taskwarrior-tui
      tasksh
    ];
  };
}
