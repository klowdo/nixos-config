{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.hyprmoncfg;
in {
  options.services.hyprmoncfg = {
    enable = mkEnableOption "hyprmoncfg - Hyprland monitor profile manager";

    package = mkOption {
      type = types.package;
      default = pkgs.hyprmoncfg;
      defaultText = literalExpression "pkgs.hyprmoncfg";
      description = "The hyprmoncfg package to install.";
    };

    systemdTarget = mkOption {
      type = types.str;
      default = "graphical-session.target";
      example = "hyprland-session.target";
      description = "Systemd target to bind the daemon to.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.hyprmoncfg" pkgs
        lib.platforms.linux)
    ];

    home.packages = [cfg.package];

    systemd.user.services.hyprmoncfgd = {
      Unit = {
        Description = "Hyprland monitor profile daemon";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = cfg.systemdTarget;
        Requires = cfg.systemdTarget;
        After = cfg.systemdTarget;
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/hyprmoncfgd";
        Restart = "on-failure";
        RestartSec = 2;
      };

      Install = {
        WantedBy = [cfg.systemdTarget];
      };
    };
  };
}
