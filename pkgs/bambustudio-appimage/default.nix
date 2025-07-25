{
  fetchurl,
  appimageTools,
  lib,
}: let
  pname = "bambustudio";
  version = "02.00.02.58";

  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v02.00.02.57/Bambu_Studio_linux_fedora-v02.00.02.58.AppImage";
    sha256 = "sha256-9eW5PGuOj1PcJMvDE5Y7itEQVZCh+jMoaFp5Pre8uRQ=";
    name = "Bambu_Studio_linux_fedora-v02.00.02.58.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [
      libGL
      libGLU
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      gtk3
      glib
      fontconfig
      freetype
    ];

    extraInstallCommands = ''
      # Install desktop file if it exists
      if [ -f ${appimageContents}/bambu-studio.desktop ]; then
        install -m 444 -D ${appimageContents}/bambu-studio.desktop $out/share/applications/${pname}.desktop
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace 'Exec=AppRun' 'Exec=${pname}'
      fi
      
      # Install icon if it exists
      for icon in ${appimageContents}/*.png ${appimageContents}/*.svg; do
        if [ -f "$icon" ]; then
          install -m 444 -D "$icon" $out/share/pixmaps/$(basename "$icon")
          break
        fi
      done
    '';

    meta = with lib; {
      description = "PC Software for BambuLab's 3D printers";
      homepage = "https://bambulab.com/en/download/studio";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = [];
    };
  }