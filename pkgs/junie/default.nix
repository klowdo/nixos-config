# nix-update: junie
{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  zlib,
  pcsclite,
  xorg,
  harfbuzz,
  freetype,
  libjpeg8,
  lcms2,
  giflib,
  alsa-lib,
}:
stdenv.mkDerivation rec {
  pname = "junie";
  version = "888.219";

  src = fetchurl {
    url = "https://github.com/JetBrains/junie/releases/download/${version}/junie-release-${version}-linux-amd64.zip";
    sha256 = "48f208b55a6cfa75bf2b4999bb2fa1e31103aff76b4402768f8c227743229f25";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc
    zlib
    pcsclite
    xorg.libX11
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    harfbuzz
    freetype
    libjpeg8
    lcms2
    giflib
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,libexec}
    cp -r junie-app $out/libexec/junie-app
    makeWrapper $out/libexec/junie-app/bin/junie $out/bin/junie

    runHook postInstall
  '';

  meta = with lib; {
    description = "AI coding agent by JetBrains that lives in your terminal";
    homepage = "https://github.com/JetBrains/junie";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "junie";
  };
}
