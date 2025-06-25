{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.cura;

  curaAppImage = pkgs.fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/5.10.0/UltiMaker-Cura-5.10.0-linux-X64.AppImage";
    sha256 = "153zsp50aanb04zv02hlv6gvhk0g94rcm5yc78kqd6vlvgivdagh";
    name = "UltiMaker-Cura-5.10.0-linux-X64.AppImage";
  };

  curaWrapper = pkgs.writeShellScriptBin "ultimaker-cura" ''
    #!${pkgs.bash}/bin/bash
    exec ${pkgs.appimage-run}/bin/appimage-run ${curaAppImage} "$@"
  '';
in {
  options.features.development.cura.enable = mkEnableOption "enable UltiMaker Cura 3D printing slicer";

  config = mkIf cfg.enable {
    home.packages = [
      # curaWrapper
      pkgs.unstable.cura-appimage
      # pkgs.unstable.curaPlugins
      # pkgs.ultimaker-cura
      # pkgs.appimage-run
    ];
    #
    #   xdg.desktopEntries.ultimaker-cura = {
    #     name = "UltiMaker Cura";
    #     genericName = "3D Printing Slicer";
    #     comment = "Prepare your 3D models for printing";
    #     exec = "ultimaker-cura %F";
    #     icon = "cura";
    #     terminal = false;
    #     categories = [
    #       "Graphics"
    #       "3DGraphics"
    #       "Engineering"
    #     ];
    #     type = "Application";
    #     mimeType = [
    #       "model/stl"
    #       "application/vnd.ms-3mfdocument"
    #       "application/prs.wavefront-obj"
    #       "model/x3d+xml"
    #       "model/gltf+json"
    #       "model/gltf-binary"
    #     ];
    #     startupNotify = true;
    #   };
    #
    #   # Set Cura as default application for 3D model files
    #   xdg.mimeApps.defaultApplications = {
    #     "model/stl" = "ultimaker-cura.desktop";
    #     "application/vnd.ms-3mfdocument" = "ultimaker-cura.desktop";
    #     "application/prs.wavefront-obj" = "ultimaker-cura.desktop";
    #   };
  };
}
