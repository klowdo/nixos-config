{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.datagrip;
  inherit (pkgs.unstable.jetbrains) plugins;
# https://www.jetbrains.com/datagrip/download/other.html
  datagripPkg = pkgs.unstable.jetbrains.datagrip.overrideAttrs
    (_old: {
      src = pkgs.fetchurl {
        url = "https://download.jetbrains.com/datagrip/datagrip-2025.2.4.tar.gz";
        hash = "sha256-N9CvTsMLlMcdNQf+NbOwvdOJkD234vGo7XM1OyJxhHY=";
      };
      # https://www.jetbrains.com/rider/download/other.html
      version = "2025.2.4";
      build_number = "252.26830.46";

    });
  # Extract version from DataGrip package (e.g., "2025.1.2" -> "2025.1")
  datagripVersion = builtins.concatStringsSep "." (take 2 (splitString "." datagripPkg.version));
in {
  options.features.development.tools.datagrip.enable = mkEnableOption "enable DataGrip IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (plugins.addPlugins datagripPkg [
      ])
    ];

    home.file.".config/JetBrains/DataGrip${datagripVersion}/datagrip64.vmoptions".text = ''
      -Dawt.toolkit.name=WLToolkit
      -Dsun.java2d.xrender.enabled=true
      -Dsun.java2d.pmoffscreen=false
    '';
  };
}
