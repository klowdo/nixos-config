{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.goland;
  inherit (pkgs.unstable.jetbrains) plugins;
# https://www.jetbrains.com/go/download/other.html
  golandPkg = pkgs.unstable.jetbrains.goland.overrideAttrs
    (_old: {
      src = pkgs.fetchurl {
        url = "https://download.jetbrains.com/go/goland-2025.2.4.tar.gz";
        hash = "sha256-+0KXjVUnHm+jFlsdAQs+C6y4zVxPQHNxIzLGLzLS66s=";
      };
      # https://www.jetbrains.com/rider/download/other.html
      version = "2025.2.4";
      build_number = "252.26830.102";

    });
  # Extract version from GoLand package (e.g., "2025.1.2" -> "2025.1")
  golandVersion = builtins.concatStringsSep "." (take 2 (splitString "." golandPkg.version));
in {
  options.features.development.tools.goland.enable = mkEnableOption "enable goland IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (plugins.addPlugins golandPkg [
        # "github-copilot"
        "ideavim"
      ])
    ];

    home.file.".config/JetBrains/GoLand${golandVersion}/goland64.vmoptions".text = ''
      # custom GoLand VM options (expand/override 'bin/goland64.vmoptions')

      -Dawt.toolkit.name=WLToolkit
    '';
  };
}
