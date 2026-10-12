{...}: {
  flake.modules.homeManager.bambu-studio = {pkgs, ...}: {
    home.packages = [
      pkgs.bambustudio-appimage
    ];

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
  };
}
