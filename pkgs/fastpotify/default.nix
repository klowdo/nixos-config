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
    version = "0.4.1";

    src = fetchFromGitHub {
      owner = "crmne";
      repo = "fastpotify";
      tag = "v${version}";
      hash = "sha256-z/g5T2qR7nyBbxeSDEJ8GVRkyrkX/6F6GOLUa7lvgMM=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";

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
