# nix-update: herdr-bar
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-bar";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    rev = "v${version}";
    hash = "sha256-jwg5x3GCRAaHNhBmwCkjTTef0/ma9pdwtEC5FHvRewY=";
  };

  cargoHash = "sha256-9nx8PHmGYKx8+i0+t1Ve40KjZKF036Dv7CWXQ2GiWEI=";

  doCheck = false;

  postInstall = ''
    cp -r $src/. $out/
  '';

  passthru.herdrPlugin = {
    id = "herdr-bar";
    name = "Bar";
    minHerdrVersion = "0.9.0";
  };

  meta = {
    description = "Command bar with agent icons and fuzzy search for herdr";
    homepage = "https://github.com/jeffarese/herdr-bar";
    license = lib.licenses.mit;
    mainProgram = "herdr-bar";
  };
}
