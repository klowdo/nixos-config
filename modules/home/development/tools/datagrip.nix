{...}: {
  flake.modules.homeManager.datagrip = {
    lib,
    pkgs,
    ...
  }:
    with lib; let
      inherit (pkgs.unstable.jetbrains) plugins;
      datagripPkg = pkgs.jetbrains-datagrip;
      datagripVersion = concatStringsSep "." (take 2 (splitString "." datagripPkg.version));
    in {
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
