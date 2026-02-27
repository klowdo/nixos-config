#
{
  fetchurl,
  appimageTools,
}: let
  pname = "appimagetool";
  version = "1.9.0";

  src = fetchurl {
    url = "https://github.com/AppImage/appimagetool/releases/download/${version}/appimagetool-x86_64.AppImage";
    sha256 = "1lc3c38033392x5lnr1z4jmqx3fryfqczbv1bda6wzsc162xgza6";
    name = "appimagetool-x86_64.AppImage";
  };
  # appimageContents = appimageTools.extractType2 {
  #   inherit pname version src;
  # };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [zsync appstream file];

    # extraInstallCommands = ''
    #   # install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    #   # substituteInPlace $out/share/applications/${pname}.desktop \
    #   #   --replace 'Exec=AppRun' 'Exec=${pname}'
    #
    #   # install -m 444 -D ${appimageContents}/cura.png
    #
    #   # mv $out/bin/${pname}-${version} $out/bin/${pname}
    #   # install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    #   # substituteInPlace $out/share/applications/${pname}.desktop \
    #   #   --replace 'Exec=AppRun' 'Exec=${pname}'
    # '';
  }
