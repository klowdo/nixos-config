{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
  writeShellScript,
}: let
  pname = "deezer-linux";
  version = "7.0.110";

  src = fetchurl {
    url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x86_64.AppImage";
    sha256 = "1jixbx2d6mflgxivm2kckb0s6s225rkyj20lh10asxhynw170hkv";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
          # The appimageTools creates a binary with a different name pattern
          # Let's check what binary exists and rename accordingly
          if [ -f $out/bin/${pname} ]; then
            # Binary already has the right name
            echo "Binary already correctly named"
          elif [ -f $out/bin/deezer-desktop ]; then
            mv $out/bin/deezer-desktop $out/bin/${pname}
          else
            # List what's actually in the bin directory for debugging
            echo "Available binaries:" && ls -la $out/bin/
          fi

          # Install desktop file and icon
          mkdir -p $out/share/applications $out/share/pixmaps

          # Try to use desktop file from AppImage, otherwise create our own
          if [ -f ${appimageContents}/deezer-desktop.desktop ]; then
            install -m 444 -D ${appimageContents}/deezer-desktop.desktop $out/share/applications/deezer-linux.desktop
            substituteInPlace $out/share/applications/deezer-linux.desktop \
              --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U' \
              --replace 'Icon=deezer-desktop' 'Icon=deezer-linux'
          else
            # Create our own desktop file
            cat > $out/share/applications/deezer-linux.desktop << EOF
      [Desktop Entry]
      Name=Deezer
      GenericName=Music Streaming
      Comment=Listen to music on Deezer
      Exec=${pname} %U
      Icon=deezer-linux
      Type=Application
      StartupNotify=true
      Categories=Audio;Music;Player;AudioVideo;
      MimeType=x-scheme-handler/deezer;
      EOF
          fi

          # Install icon from AppImage or use a fallback
          if [ -f ${appimageContents}/deezer-desktop.png ]; then
            install -m 444 -D ${appimageContents}/deezer-desktop.png $out/share/pixmaps/deezer-linux.png
          elif [ -f ${appimageContents}/usr/share/pixmaps/deezer-desktop.png ]; then
            install -m 444 -D ${appimageContents}/usr/share/pixmaps/deezer-desktop.png $out/share/pixmaps/deezer-linux.png
          else
            # Create a simple text-based icon as fallback
            echo "No icon found, you may want to add one manually"
          fi
    '';

    meta = with lib; {
      description = "Unofficial Linux desktop app for Deezer music streaming";
      homepage = "https://github.com/aunetx/deezer-linux";
      license = licenses.unfree;
      maintainers = [];
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
