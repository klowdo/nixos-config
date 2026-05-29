{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.greetd;
in {
  options.extraServices.greetd.enable = mkEnableOption "greetd display manager";

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd 'uwsm start hyprland-uwsm.desktop'";
          user = "greeter";
        };
      };
    };
  };
}
