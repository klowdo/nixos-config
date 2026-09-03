# nix-update: fastpotify
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  alsa-lib,
  libpulseaudio,
  libxkbcommon,
  wayland,
  libGL,
  xorg,
}: let
  runtimeLibs = [
    libxkbcommon
    wayland
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];
in
  rustPlatform.buildRustPackage rec {
    pname = "fastpotify";
    version = "0.5.0";

    src = fetchFromGitHub {
      owner = "crmne";
      repo = "fastpotify";
      tag = "v${version}";
      hash = "sha256-mXpmzF3GDttcF6d/3vyTyc2kBC1bTFOhnKI6qGBJG2c=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "librespot-audio-0.8.0" = "sha256-RtuFuHywWn5sdAMjjAyv8d3n/pEol6F28HGjdTtWixM=";
      "projectm-sys-1.2.3" = "sha256-sgI6IOCpQUvdc5acQ1wjCM5mhfz2EPZmoeuyNLGB5UI=";
    };

    nativeBuildInputs = [
      pkg-config
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      libpulseaudio
    ];

    postInstall = ''
      install -Dm644 packaging/applications/fastpotify.desktop \
        $out/share/applications/fastpotify.desktop
      install -Dm644 packaging/icons/fastpotify.svg \
        $out/share/icons/hicolor/scalable/apps/fastpotify.svg
    '';

    postFixup = ''
      wrapProgram $out/bin/fastpotify \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
    '';

    meta = with lib; {
      description = "Fast native Spotify client with local playback and Spotify Connect";
      homepage = "https://fastpotify.rocks";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = "fastpotify";
    };
  }
