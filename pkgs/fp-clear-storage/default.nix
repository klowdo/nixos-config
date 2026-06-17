{
  lib,
  stdenv,
  pkg-config,
  makeWrapper,
  libfprint-tod,
  glib,
  libfprint-2-tod1-goodix,
}:
stdenv.mkDerivation {
  pname = "fp-clear-storage";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [pkg-config makeWrapper];
  buildInputs = [libfprint-tod glib];

  buildPhase = ''
    runHook preBuild
    cc fp-clear.c -o fp-clear-storage $(pkg-config --cflags --libs libfprint-2 glib-2.0 gobject-2.0)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp fp-clear-storage $out/bin/
    wrapProgram $out/bin/fp-clear-storage \
      --set FP_TOD_DRIVERS_DIR ${libfprint-2-tod1-goodix}/lib/libfprint-2/tod-1
    runHook postInstall
  '';

  meta = {
    description = "Wipe on-chip fingerprint storage on Goodix MOC sensors via libfprint-tod";
    platforms = lib.platforms.linux;
    mainProgram = "fp-clear-storage";
  };
}
