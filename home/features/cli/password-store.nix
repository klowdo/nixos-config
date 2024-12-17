{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.password-store;
in {
  options.features.cli.password-store.enable = mkEnableOption "enable password-store";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
    ];
    programs.password-store = {
      enable = true;
    };
  };
}
