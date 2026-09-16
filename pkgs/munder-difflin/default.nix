# nix-update: munder-difflin
{
  fetchurl,
  appimageTools,
  lib,
}: let
  pname = "munder-difflin";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/chaitanyagiri/munder-difflin/releases/download/v${version}/Munder-Difflin-${version}-linux-x86_64.AppImage";
    hash = "sha256-6GN7epjX6LQXol7Xj05hvuxqQoE/CJCEjKqsiVPHEwo=";
    name = "Munder-Difflin-${version}-linux-x86_64.AppImage";
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
        libGL
        libGLU

        libx11
        libxext
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb

        gtk3
        glib
        cairo
        pango
        gdk-pixbuf
        atk

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

        fontconfig
        freetype

        openssl

        libnotify
        libappindicator-gtk3
        libpulseaudio
      ];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'

      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/${pname}.png \
        $out/share/icons/hicolor/512x512/apps/${pname}.png
    '';

    meta = with lib; {
      description = "Local multi-agent harness that runs an office of terminal coding agents";
      homepage = "https://github.com/chaitanyagiri/munder-difflin";
      license = licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = pname;
      maintainers = [];
    };
  }
