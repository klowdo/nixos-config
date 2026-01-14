{
  fetchurl,
  appimageTools,
  lib,
}:
let
  pname = "auto-claude";
  version = "2.7.4";

  src = fetchurl {
    url = "https://github.com/AndyMik90/Auto-Claude/releases/download/v${version}/Auto-Claude-${version}-linux-x86_64.AppImage";
    hash = "sha256-8aq8WEv64ZpeEVkEU3+L6n2doP8AFeKM8BcnA+thups=";
    name = "Auto-Claude-${version}-linux-x86_64.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraBwrapArgs = [
    "--setenv APPIMAGE 1"
  ];

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
      xorg.libXtst
      xorg.libxcb

      # GTK and UI dependencies
      gtk3
      glib
      cairo
      pango
      gdk-pixbuf
      atk

      # Electron dependencies
      alsa-lib
      nss
      nspr
      cups
      dbus
      expat
      at-spi2-atk
      at-spi2-core
      libdrm
      mesa

      # Font rendering
      fontconfig
      freetype

      # TLS/SSL support
      openssl

      # Additional dependencies for Node.js/Electron apps
      libnotify
      libappindicator-gtk3
      libpulseaudio
    ];

  extraInstallCommands = ''
    # Install desktop file
    install -m 444 -D ${appimageContents}/auto-claude-ui.desktop $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Icon=auto-claude-ui' 'Icon=auto-claude'

    # Install icon
    install -m 444 -D ${appimageContents}/auto-claude-ui.png $out/share/pixmaps/auto-claude.png
  '';

  meta = with lib; {
    description = "Autonomous multi-agent coding framework powered by Claude AI";
    homepage = "https://github.com/AndyMik90/Auto-Claude";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = [];
  };
}
