{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.way-displays;

  # Types for validation
  arrangeType = types.enum ["ROW" "COLUMN"];
  alignType = types.enum ["TOP" "MIDDLE" "BOTTOM" "LEFT" "RIGHT"];
  transformType = types.enum ["90" "180" "270" "FLIPPED" "FLIPPED-90" "FLIPPED-180" "FLIPPED-270"];
  logThresholdType = types.enum ["ERROR" "WARNING" "INFO" "DEBUG"];

  # Helper function to render floats without unnecessary decimals
  renderFloat = float: let
    # Convert to string and split by "."
    str = builtins.toString float;
    parts = builtins.split "\\." str;
  in
    if length parts == 1
    then str
    else let
      # Remove trailing zeros from decimal part
      decimals = elemAt parts 2;
      cleaned = removeSuffix "0" (
        removeSuffix "0" (
          removeSuffix "0" (
            removeSuffix "0" (
              removeSuffix "0" decimals
            )
          )
        )
      );
    in
      if cleaned == ""
      then elemAt parts 0
      else "${elemAt parts 0}.${cleaned}";

  # Format mode configuration entries
  formatMode = mode: ''
    - ${
      if mode.nameDesc != null
      then "NAME_DESC: '${mode.nameDesc}'"
      else "NAME: '${mode.name}'"
    }
        ${optionalString (mode.width != null) "WIDTH: ${toString mode.width}"}
        ${optionalString (mode.height != null) "HEIGHT: ${toString mode.height}"}
        ${optionalString (mode.hz != null) "HZ: ${toString mode.hz}"}
        ${optionalString (mode.max) "MAX: TRUE"}
  '';

  # Format scale entries
  formatScale = scale: ''
    - ${
      if scale.nameDesc != null
      then "NAME_DESC: '${scale.nameDesc}'"
      else "NAME: '${scale.name}'"
    }
        SCALE: ${renderFloat scale.scale}
  '';

  # Format transform entries
  formatTransform = transform: ''
    - ${
      if transform.nameDesc != null
      then "NAME_DESC: '${transform.nameDesc}'"
      else "NAME: '${transform.name}'"
    }
       TRANSFORM: ${transform.transform}
  '';

  # Generate the config file
  configFile = ''
    # Generated via Home Manager configuration
    # See https://github.com/alex-courtis/way-displays/wiki/Configuration

    # Arrange displays in a ROW (left to right) or a COLUMN (top to bottom)
    ARRANGE: ${cfg.arrange}

    # Align ROWs at the TOP, MIDDLE or BOTTOM
    # Align COLUMNs at the LEFT, MIDDLE or RIGHT
    ALIGN: ${cfg.align}

    ${optionalString (cfg.order != []) ''
      # Define display order
      ORDER:
        ${concatMapStringsSep "\n  " (name: "- '${name}'") cfg.order}
    ''}

    # Enable scaling, overrides AUTO_SCALE and SCALE
    SCALING: ${
      if cfg.scaling
      then "TRUE"
      else "FALSE"
    }

    # The default is to scale each display by DPI
    AUTO_SCALE: ${
      if cfg.autoScale
      then "TRUE"
      else "FALSE"
    }

    ${optionalString (cfg.autoScaleMin != null) ''
      # Set a minimum value for auto scale
      AUTO_SCALE_MIN: ${renderFloat cfg.autoScaleMin}
    ''}

    ${optionalString (cfg.autoScaleMax != null) ''
      # Set a maximum value for auto scale
      AUTO_SCALE_MAX: ${renderFloat cfg.autoScaleMax}
    ''}

    ${optionalString (cfg.scales != []) ''
      # Override automatic scaling for specific displays
      SCALE:
        ${concatMapStringsSep "\n  " formatScale cfg.scales}
    ''}

    ${optionalString (cfg.modes != []) ''
      # Override the preferred mode for displays
      MODE:
        ${concatMapStringsSep "\n  " formatMode cfg.modes}
    ''}

    ${optionalString (cfg.transforms != []) ''
      # Rotate or translate displays
      TRANSFORM:
        ${concatMapStringsSep "\n  " formatTransform cfg.transforms}
    ''}

    ${optionalString (cfg.vrrOff != []) ''
      # Disable VRR / adaptive sync for specific displays
      VRR_OFF:
        ${concatMapStringsSep "\n  " (name: "- '${name}'") cfg.vrrOff}
    ''}

    ${optionalString (cfg.changeSuccessCmd != null) ''
      # Command to run when display configuration changes
      CHANGE_SUCCESS_CMD: '${cfg.changeSuccessCmd}'
    ''}

    ${optionalString (cfg.laptopDisplayPrefix != null) ''
      # Prefix for laptop displays
      LAPTOP_DISPLAY_PREFIX: '${cfg.laptopDisplayPrefix}'
    ''}

    # Logging level
    LOG_THRESHOLD: ${cfg.logThreshold}

    ${optionalString (cfg.disabled != []) ''
      # Disabled displays
      DISABLED:
        ${concatMapStringsSep "\n  " (name: "- '${name}'") cfg.disabled}
    ''}

    ${cfg.extraConfig}
  '';
in {
  meta.maintainers = with lib.hm.maintainers; [];

  options.services.custom-way-displays = {
    enable = mkEnableOption "way-displays display management tool for Wayland";

    package = mkOption {
      type = types.package;
      default = pkgs.way-displays;
      defaultText = literalExpression "pkgs.way-displays";
      description = "way-displays package to use.";
    };

    arrange = mkOption {
      type = arrangeType;
      default = "ROW";
      description = "Arrange displays in a ROW (left to right) or a COLUMN (top to bottom).";
    };

    align = mkOption {
      type = alignType;
      default = "TOP";
      description = ''
        Alignment of displays.
        For ROW: TOP, MIDDLE, or BOTTOM.
        For COLUMN: LEFT, MIDDLE, or RIGHT.
      '';
    };

    order = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["DP-2" "monitor description" "HDMI-1"];
      description = "Define the order of displays.";
    };

    scaling = mkOption {
      type = types.bool;
      default = true;
      description = "Enable scaling, overrides autoScale and scale options.";
    };

    autoScale = mkOption {
      type = types.bool;
      default = true;
      description = "Scale each display by DPI. When disabled, scale 1 is used unless a specific scale is set.";
    };

    autoScaleMin = mkOption {
      type = types.nullOr types.float;
      default = null;
      example = 1.0;
      description = "Minimum value for auto scale.";
    };

    autoScaleMax = mkOption {
      type = types.nullOr types.float;
      default = null;
      example = 2.0;
      description = "Maximum value for auto scale.";
    };

    scales = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Display name to scale.";
          };

          nameDesc = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Display description to scale.";
          };

          scale = mkOption {
            type = types.float;
            description = "Scale factor to apply.";
          };
        };
      });
      default = [];
      example = [
        {
          nameDesc = "Samsung Display Corp. 0x414D";
          scale = 1.5;
        }
      ];
      description = "Scale settings for specific displays.";
    };

    modes = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Display name to configure.";
          };

          nameDesc = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Display description to configure.";
          };

          width = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Desired display width.";
          };

          height = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Desired display height.";
          };

          hz = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Desired refresh rate.";
          };

          max = mkOption {
            type = types.bool;
            default = false;
            description = "Use highest available mode.";
          };
        };
      });
      default = [];
      example = [
        {
          nameDesc = "Samsung Display";
          width = 3456;
          height = 2160;
          hz = 60;
        }
        {
          nameDesc = "HP Z40c";
          max = true;
        }
      ];
      description = "Mode settings for specific displays.";
    };

    transforms = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Display name to transform.";
          };

          nameDesc = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Display description to transform.";
          };

          transform = mkOption {
            type = transformType;
            description = "Transform to apply (rotation/flip).";
          };
        };
      });
      default = [];
      example = [
        {
          nameDesc = "Monitor description";
          transform = "270";
        }
      ];
      description = "Transform settings for specific displays.";
    };

    vrrOff = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["eDP-1" "DP-4"];
      description = "Displays for which to disable VRR/adaptive sync.";
    };

    changeSuccessCmd = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "bell ; notify-send way-displays \"Monitor changed\"";
      description = "Command to run after a successful display configuration change.";
    };

    laptopDisplayPrefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "eDP";
      description = "Prefix for laptop displays.";
    };

    logThreshold = mkOption {
      type = logThresholdType;
      default = "INFO";
      description = "Logging level (ERROR, WARNING, INFO, DEBUG).";
    };

    disabled = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["eDP-1"];
      description = "Displays to disable.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra configuration lines to append to the way-displays
        configuration file.
      '';
    };

    #TODO: use wayload systemd.target
    # systemdTarget = mkOption {
    #   type = types.str;
    #   default = config.wayland.systemd.target;
    #   defaultText = literalExpression "config.wayland.systemd.target";
    #   description = ''
    #     Systemd target to bind to.
    #   '';
    # };

    systemdTarget = mkOption {
      type = types.str;
      default = "graphical-session.target";
      example = "hyprland-session.target";
      description = ''
        Systemd target to bind to.
      '';
    };

    enableHyprlandSupport = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Hyprland-specific configuration, including adding
        'debug:disable_scale_checks = true' to Hyprland config.
        Requires wayland.windowManager.hyprland.enable to be true.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        (lib.hm.assertions.assertPlatform "services.way-displays" pkgs
          lib.platforms.linux)
        {
          assertion = !cfg.enableHyprlandSupport || config.wayland.windowManager.hyprland.enable;
          message = "services.way-displays.enableHyprlandSupport requires wayland.windowManager.hyprland.enable to be true";
        }
      ];

      #TODO: make this optional
      home.packages = [cfg.package];

      #TODO: make this optional
      xdg.configFile."way-displays/cfg.yaml".text = configFile;

      # Hyprland integration
      wayland.windowManager.hyprland.settings = mkIf cfg.enableHyprlandSupport {
        debug = {
          disable_scale_checks = true;
        };
      };

      systemd.user.services.way-displays = {
        Unit = {
          Description = "Manage displays in Wayland compositors";
          Documentation = "man:way-displays(1)";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = cfg.systemdTarget;
          Requires = cfg.systemdTarget;
          After = cfg.systemdTarget;
        };

        Service = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/way-displays";
          Restart = "always";
        };

        Install = {
          WantedBy = [cfg.systemdTarget];
        };
      };
    }
  ]);
}
