{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  webkitgtk_4_1,
  openssl,
  glib-networking,
  wrapGAppsHook3,
  bun,
  cargo,
  nodejs,
  nodePackages,
}: let
  pname = "claudia";
  version = "unstable-2024-07-08";
in
  rustPlatform.buildRustPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "getAsterisk";
      repo = "claudia";
      rev = "cee71343f5ddf98822bff36caf785601132d6158";
      sha256 = "0r7wk6dkl98ip6ismr9qn9ng71cqlabsqagw4qk8dqayfamc8fhw";
    };

    cargoHash = "sha256-unVKAZ71CvxVqUCBFMKqgKreHXUBae3+Qy5Fw8fMcl8=";

    # The Cargo.lock is in src-tauri directory
    sourceRoot = "source/src-tauri";

    nativeBuildInputs = [
      pkg-config
      wrapGAppsHook3
      bun
      cargo
      nodejs
      nodePackages.npm
      rustPlatform.cargoSetupHook
    ];

    buildInputs = [
      webkitgtk_4_1
      openssl
      glib-networking
    ];

    # Build frontend and prepare Claude Code binary
    preBuild = ''
      # Create a stub binary to satisfy the build requirement
      mkdir -p binaries
      echo '#!/bin/sh' > binaries/claude-code-x86_64-unknown-linux-gnu
      echo 'echo "Claude Code CLI stub - install real binary separately"' >> binaries/claude-code-x86_64-unknown-linux-gnu
      chmod +x binaries/claude-code-x86_64-unknown-linux-gnu

      cd ..

      # Install dependencies
      bun install --frozen-lockfile

      # Build frontend
      bun run build
      cd src-tauri
    '';

    # Use regular cargo build instead of tauri build
    buildPhase = ''
      cargo build --release
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp target/release/claudia $out/bin/
    '';

    meta = with lib; {
      description = "Claude desktop app built with Tauri";
      homepage = "https://github.com/getAsterisk/claudia";
      license = licenses.mit;
      platforms = platforms.linux;
      maintainers = [];
    };
  }
