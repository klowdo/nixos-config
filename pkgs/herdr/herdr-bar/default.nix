# nix-update: herdr-bar
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-bar";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    rev = "v${version}";
    hash = "sha256-7ybX/DwOZkI7yr0U6fszlerx5/96mGO9DtLXoA4DuHs=";
  };

  cargoHash = "sha256-6aTRYRoG2bkVZiMmGWQoBEmimMUIzQGd/eeSjqboLEw=";

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
