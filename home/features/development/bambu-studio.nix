{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.bambu-studio;
in {
  options.features.development.bambu-studio.enable = mkEnableOption "enable bambu-studio 3D printing slicer";

  config = mkIf cfg.enable {
    # Install BambuStudio via AppImage (with proper webkit2gtk and TLS support)
    home.packages = [
      pkgs.bambustudio-appimage
    ];

    # Create desktop entry for BambuStudio
    xdg.desktopEntries.bambustudio = {
      name = "BambuStudio";
      genericName = "3D Printing Software";
      comment = "PC Software for BambuLab's 3D printers";
      exec = "bambustudio";
      icon = "bambustudio";
      terminal = false;
      type = "Application";
      categories = ["Graphics" "3DGraphics" "Engineering"];
      mimeType = [
        "model/stl"
        "model/3mf"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "application/x-amf"
        "x-scheme-handler/bambustudio"
      ];
      startupNotify = true;
    };

    # Flatpak alternative (commented out)
    # Note: This requires enabling features.development.nix-flatpak.enable = true;
    # services.flatpak.packages = [
    #   {
    #     appId = "com.bambulab.BambuStudio";
    #     origin = "flathub";
    #   }
    # ];
  };
}
