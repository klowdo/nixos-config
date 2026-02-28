{
  lib,
  fetchurl,
  appimageTools,
}: let
  pname = "numara-calculator";
  version = "6.5.2";

  src = fetchurl {
    url = "https://github.com/bornova/numara-calculator/releases/download/v${version}/Numara-${version}-x86_64.AppImage";
    sha256 = "sha256-m0RCeWFHRRDaQ7HXn9of/PHqV9A+xsai2gCxKQq3ky4=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/numara.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/numara.png \
        $out/share/icons/hicolor/512x512/apps/${pname}.png
    '';

    meta = with lib; {
      description = "A simple but powerful notepad calculator";
      longDescription = ''
        Numara is a notepad calculator built with Electron and Math.js.
        It evaluates mathematical expressions as you type, combining
        the simplicity of a notepad with powerful calculation capabilities.
      '';
      homepage = "https://numara.io";
      downloadPage = "https://github.com/bornova/numara-calculator/releases";
      license = licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
