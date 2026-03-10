## Not used but saved for future appimages
{
  fetchurl,
  appimageTools,
}: let
  pname = "Ulitmaker Cura";
  version = "5.10.0";

  src = fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/${version}/UltiMaker-Cura-${version}-linux-X64.AppImage";
    sha256 = "153zsp50aanb04zv02hlv6gvhk0g94rcm5yc78kqd6vlvgivdagh";
    name = "UltiMaker-Cura-${version}-linux-X64.AppImage";
  };
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 rec {
    inherit pname version src;

    # extraPkgs = pkgs: with pkgs; [];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'

      # install -m 444 -D ${appimageContents}/cura.png

      # mv $out/bin/${pname}-${version} $out/bin/${pname}
      # install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
      # substituteInPlace $out/share/applications/${pname}.desktop \
      #   --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  }
