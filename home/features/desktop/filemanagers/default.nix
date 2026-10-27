{
  config,
  lib,
  ...
}:
with lib; let
  supported = ["thunar" "nautilus" "omafiles"];
  enabled = filter (fm: config.features.desktop.${fm}.enable) supported;
in {
  imports = [
    ./thunar.nix
    ./nautilus.nix
    ./omafiles.nix
  ];

  config = {
    # Assertion: Only one file manager should be enabled at a time
    assertions = [
      {
        assertion = length enabled <= 1;
        message = "Only one file manager can be enabled at a time. Please enable exactly one of: ${concatStringsSep ", " supported} (currently enabled: ${concatStringsSep ", " enabled}).";
      }
      {
        assertion = enabled != [] || !config.features.defaults.enable;
        message = "At least one file manager must be enabled when features.defaults is enabled.";
      }
    ];

    # Automatically set fileManager.type based on which file manager is enabled
    features.defaults.fileManager.type = mkIf config.features.defaults.enable (
      if enabled == []
      then "thunar"
      else head enabled
    );
  };
}
