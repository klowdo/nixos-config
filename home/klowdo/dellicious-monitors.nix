{
  config,
  inputs,
  ...
}: {
  # HyprDynamicMonitors - Profile-based monitor management
  imports = [
    inputs.hyprdynamicmonitors.homeManagerModules.hyprdynamicmonitors
  ];
  home = {
    packages = [
      config.home.hyprdynamicmonitors.package
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
  xdg.configFile = {
    "hyprdynamicmonitors/hyprconfigs/laptop-only.conf".source = ./monitors/hyprconfigs/laptop-only.conf;
    "hyprdynamicmonitors/hyprconfigs/home-tv.conf".source = ./monitors/hyprconfigs/home-tv.conf;
    "hyprdynamicmonitors/hyprconfigs/home-monitor.conf".source = ./monitors/hyprconfigs/home-monitor.conf;
    "hyprdynamicmonitors/hyprconfigs/work-desk.conf".source = ./monitors/hyprconfigs/work-desk.conf;
    "hyprdynamicmonitors/hyprconfigs/office-thunderbolt.conf".source = ./monitors/hyprconfigs/office-thunderbolt.conf;
  };
}
