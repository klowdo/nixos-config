{
  fetchurl,
  appimageTools,
  lib,
  cacert,
  glib-networking,
  webkitgtk_4_1,
}: let
  pname = "bambustudio";
  version = "02.05.00.65";

  pr = "9504";

  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-24.04_PR-${pr}.AppImage";
    sha256 = "sha256-tVjzyV0kEf5kx0C4PvxeS3+FOQZKtPuVRJkiLeQQFhc=";
    name = "Bambu_Studio_ubuntu-24.04_PR-${pr}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs:
      with pkgs; [
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
        webkitgtk_4_1
        # webkitgtk-compat  # Custom package providing 4.0 -> 4.1 compat symlink

        # Font rendering
        fontconfig
        freetype

        # TLS/SSL support (fixes TLS error)
        openssl
        glib-networking # Provides GIO TLS backends
        cacert # Provides SSL certificate bundle

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
      # Install desktop file
      if [ -f ${appimageContents}/BambuStudio.desktop ]; then
        install -m 444 -D ${appimageContents}/BambuStudio.desktop $out/share/applications/${pname}.desktop
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-fail 'Exec=AppRun' 'Exec=${pname}' \
          --replace-fail 'Icon=BambuStudio' 'Icon=${pname}'
      fi

      # Install hicolor icons
      for size in 32x32 128x128 192x192; do
        icon="${appimageContents}/usr/share/icons/hicolor/$size/apps/BambuStudio.png"
        if [ -f "$icon" ]; then
          install -m 444 -D "$icon" "$out/share/icons/hicolor/$size/apps/${pname}.png"
        fi
      done

      # Install fallback pixmap
      if [ -f ${appimageContents}/BambuStudio.png ]; then
        install -m 444 -D ${appimageContents}/BambuStudio.png $out/share/pixmaps/${pname}.png
      fi
    '';

    meta = with lib; {
      description = "PC Software for BambuLab's 3D printers";
      homepage = "https://bambulab.com/en/download/studio";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = [];
    };
  }
