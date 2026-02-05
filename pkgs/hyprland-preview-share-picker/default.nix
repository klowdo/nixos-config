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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "WhySoBad";
    repo = "hyprland-preview-share-picker";
    rev = "e056361af807058828c9075135d72b980fce318e";
    hash = "sha256-uzpRqLYxPTRxGggvkmMtZ4UBBTPw5pYl0YDzVg4UsMI=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-AqX9jKj7JLEx1SLefyaWYGbRdk0c3H/NDTIsZy6B6hY=";

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
