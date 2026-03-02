{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./thunar.nix
    ./nautilus.nix
  ];

  config = {
    # Assertion: Only one file manager should be enabled at a time
    assertions = [
      {
        assertion = !(config.features.desktop.thunar.enable && config.features.desktop.nautilus.enable);
        message = "Only one file manager can be enabled at a time. Please enable either thunar or nautilus, not both.";
      }
      {
        assertion = config.features.desktop.thunar.enable || config.features.desktop.nautilus.enable || !config.features.defaults.enable;
        message = "At least one file manager must be enabled when features.defaults is enabled.";
      }
    ];

    # Automatically set fileManager.type based on which file manager is enabled
    features.defaults.fileManager.type = mkIf config.features.defaults.enable (
      if config.features.desktop.nautilus.enable
      then "nautilus"
      else "thunar"
    );
  };
}
