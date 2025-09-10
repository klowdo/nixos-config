{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.goland;
  inherit (pkgs.unstable.jetbrains) plugins;
  golandPkg = pkgs.unstable.jetbrains.goland;
  # Extract version from GoLand package (e.g., "2025.1.2" -> "2025.1")
  golandVersion = builtins.concatStringsSep "." (take 2 (splitString "." golandPkg.version));
in {
  options.features.development.tools.goland.enable = mkEnableOption "enable goland IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (plugins.addPlugins pkgs.unstable.jetbrains.goland [
        "github-copilot"
        "ideavim"
      ])
    ];

    home.file.".config/JetBrains/GoLand${golandVersion}/goland64.vmoptions".text = ''
      # custom GoLand VM options (expand/override 'bin/goland64.vmoptions')

      -Dawt.toolkit.name=WLToolkit
    '';
  };
}
