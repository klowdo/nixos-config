# nix-update: herdr-bar
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-bar";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    rev = "v${version}";
    hash = "sha256-/7FUkN25acdtie0rIO2T1o/ZKelhsWICY2CvRk5QYxQ=";
  };

  cargoHash = "sha256-2SVfEodG2c0H4iUQaYeTwpjeReULDA+8pMkMWY5Wk0s=";

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
