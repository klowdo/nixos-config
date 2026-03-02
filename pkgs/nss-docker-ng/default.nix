{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "nss-docker-ng";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "klowdo";
    repo = "nss-docker-ng";
    rev = "573ad80538b8af960ffccd221a2373aa6812f3fb";
    hash = "sha256-g3GwhN3Ip864WeLJ31QGpGhbiLovgYx3lgNwbJFt/20=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  # Copy Cargo.lock into source since it's not in the repository
  postUnpack = ''
    cp ${./Cargo.lock} $sourceRoot/Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # This is a library, not a binary, so skip the default install
  doInstallCargoArtifacts = false;

  # Install the NSS library manually
  installPhase = ''
    runHook preInstall

    # NSS libraries expect a specific naming format: libnss_<name>.so.2
    mkdir -p $out/lib

    # Find the built library (buildRustPackage uses a target triple directory)
    find target -name "libnss_docker_ng.so" -type f
    lib_path=$(find target -name "libnss_docker_ng.so" -type f | head -1)

    if [ -z "$lib_path" ]; then
      echo "Error: Could not find libnss_docker_ng.so"
      exit 1
    fi

    cp "$lib_path" $out/lib/libnss_docker_ng.so.2

    runHook postInstall
  '';

  meta = with lib; {
    description = "Name Service Switch (NSS) plugin for Docker container discovery";
    longDescription = ''
      nss-docker-ng is a NSS plugin that enables Docker container discovery
      by ID or name through virtual .docker domain names. Users can query
      containers like my-app.docker using standard hostname resolution tools.

      After installation, you need to add 'docker_ng' to the 'hosts' line
      in /etc/nsswitch.conf.
    '';
    homepage = "https://github.com/petski/nss-docker-ng";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
  };
}
