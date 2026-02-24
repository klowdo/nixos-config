{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.datagrip;
  inherit (pkgs.unstable.jetbrains) plugins;
  datagripPkg = pkgs.jetbrains-datagrip;
  datagripVersion = concatStringsSep "." (take 2 (splitString "." datagripPkg.version));
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
