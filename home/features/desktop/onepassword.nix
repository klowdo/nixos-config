{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.onepassword;
in {
  options.features.desktop.onepassword.enable =
    mkEnableOption "1Password desktop and cli";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      _1password-gui
      _1password-cli
    ];
  };
}
