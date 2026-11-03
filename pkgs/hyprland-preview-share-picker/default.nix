# nix-update: hyprland-preview-share-picker
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  gtk4,
  gtk4-layer-shell,
}:
rustPlatform.buildRustPackage rec {
  pname = "hyprland-preview-share-picker";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "WhySoBad";
    repo = "hyprland-preview-share-picker";
    tag = "v${version}";
    hash = "sha256-0yn7YG18SC6+h3vkJNDUda/esmBl6U1tu1LHIIXSknc=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-4nd0X6Ii6pbpQgzFCw2yXhl2+C5FyqDsHtbzKNpGW5o=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
  ];

  meta = {
    description = "Alternative share picker for Hyprland with window and monitor previews";
    homepage = "https://github.com/WhySoBad/hyprland-preview-share-picker";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.linux;
    mainProgram = "hyprland-preview-share-picker";
  };
}
