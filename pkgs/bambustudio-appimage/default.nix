{
  fetchurl,
  appimageTools,
  lib,
  cacert,
  glib-networking,
}: let
  pname = "bambustudio";
  version = "02.03.00.70";

  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v02.03.00.70/Bambu_Studio_ubuntu-22.04_PR-8184.AppImage";
    sha256 = "sha256-cBkfd/zwo+eH5bwACEDjIyGsEIkoNTHHjRezA0SVRzE=";
    name = "Bambu_Studio_ubuntu-22.04_PR-8184.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [
      # Graphics libraries
      libGL
      libGLU

      # X11 libraries
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender

      # GTK and WebKit dependencies (required for embedded browser)
      gtk3
      glib
      webkitgtk_4_0  # Provides libwebkit2gtk-4.0.so.37 for Ubuntu 22.04

      # Font rendering
      fontconfig
      freetype

      # TLS/SSL support (fixes TLS error)
      openssl
      glib-networking  # Provides GIO TLS backends
      cacert  # Provides SSL certificate bundle

      # Additional dependencies
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      cairo
      pango
      gdk-pixbuf
      atk
    ];

    # Set environment variables for SSL certificates and GIO modules
    extraBwrapArgs = [
      "--setenv SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt"
      "--setenv NIX_SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt"
      "--setenv GIO_EXTRA_MODULES ${glib-networking}/lib/gio/modules"
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
