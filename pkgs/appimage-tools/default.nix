# nix-update: appimage-tools
{
  fetchurl,
  appimageTools,
}: let
  pname = "appimagetool";
  version = "1.9.1";

  src = fetchurl {
    url = "https://github.com/AppImage/appimagetool/releases/download/${version}/appimagetool-x86_64.AppImage";
    sha256 = "sha256-7UzoTw2cr/ZvULzKb/bzWq5UzoE1QIs/ozq/w8s4TrA=";
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
