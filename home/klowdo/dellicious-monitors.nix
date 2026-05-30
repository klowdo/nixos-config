{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  # HyprDynamicMonitors - Profile-based monitor management
  imports = [
    inputs.hyprdynamicmonitors.homeManagerModules.hyprdynamicmonitors
  ];
  home = {
    packages = [
      config.home.hyprdynamicmonitors.package
      pkgs.upower
    ];

    shellAliases = {
      monitor-tui = "hyprdynamicmonitors tui --config $($NH_FLAKE)home/klowdo/monitors/config.toml";
    };
    hyprdynamicmonitors = {
      enable = true;
      extraFlags = ["--enable-lid-events"];
      configFile = ./monitors/config.toml;
    };
  };

  # Create monitor config files from folder
  xdg.configFile = lib.mapAttrs' (
    filename: type:
      lib.nameValuePair "hyprdynamicmonitors/hyprconfigs/${filename}" {
        source = ./monitors/hyprconfigs/${filename};
      }
  ) (builtins.readDir ./monitors/hyprconfigs);
}
