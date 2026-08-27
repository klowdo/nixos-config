{
  inputs,
  lib,
  pkgs,
  ...
}: let
  persistentWorkspaces = ["1" "2" "3" "4" "5"];

  mkRule = workspace:
    {
      inherit workspace;
      output_key = "";
    }
    // lib.optionalAttrs (builtins.elem workspace persistentWorkspaces) {persistent = true;};

  outputDefaults = {
    enabled = true;
    transform = 0;
    bitdepth = 8;
    cm = "srgb";
    sdr_brightness = 1;
    sdr_saturation = 1;
    sdr_min_luminance = 0.2;
    sdr_max_luminance = 80;
    min_luminance = 0;
  };

  dellKey = "dell inc.|dell p2725d|gml8m84";
  samsungKey = "samsung display corp.|0x414d";

  xpektor = {
    name = "xpektor";
    created_at = "2026-08-25T06:14:20.677100288Z";
    updated_at = "2026-08-25T06:14:20.678211843Z";

    outputs = [
      (outputDefaults
        // {
          key = dellKey;
          match_key = dellKey;
          name = "DP-4";
          description = "Dell Inc. DELL P2725D GML8M84";
          make = "Dell Inc.";
          model = "DELL P2725D";
          serial = "GML8M84";
          mode = "2560x1440@59.95Hz";
          width = 2560;
          height = 1440;
          refresh = 59.95;
          x = -113;
          y = -1440;
          scale = 1;
        })
      (outputDefaults
        // {
          key = samsungKey;
          match_key = samsungKey;
          name = "eDP-1";
          description = "Samsung Display Corp. 0x414D";
          make = "Samsung Display Corp.";
          model = "0x414D";
          mode = "3456x2160@60.00Hz";
          width = 3456;
          height = 2160;
          refresh = 60;
          x = 0;
          y = 0;
          scale = 1.5;
        })
    ];

    workspaces = {
      enabled = true;
      strategy = "manual";
      max_workspaces = 9;
      group_size = 3;
      monitor_order = [samsungKey dellKey];
      rules = map mkRule ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "special:terminal"];
    };

    exec = "";
  };
in {
  imports = [
    inputs.hyprdynamicmonitors.homeManagerModules.hyprdynamicmonitors
  ];

  home = {
    packages = [pkgs.upower];
    hyprdynamicmonitors.enable = false;
  };

  services.hyprmoncfg.enable = true;

  xdg.configFile."hyprmoncfg/profiles/xpektor.json".text = builtins.toJSON xpektor;
}
