# nix-update: herdr-bar
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-bar";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    rev = "v${version}";
    hash = "sha256-KX1uB47XJdvjF02Q27bywKJ+TCkKvMpz7QPUHgGGeoA=";
  };

  cargoHash = "sha256-wfAM/xQacqyK4VGGN/Y/vl7jy5kSa7Jfb7eQo2tGTZg=";

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
