# nix-update: herdr-bar
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-bar";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    rev = "v${version}";
    hash = "sha256-CYLnUJ7BQZmtnp7X1vtqTxLjEOaWsFQ2bHyghLG8oM0=";
  };

  cargoHash = "sha256-wHAEx9lBsdKGcZjwmMSCECwjn9KR1/9MmsydgQx19oU=";

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
