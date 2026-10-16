# nix-update: herdr-projects
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-projects";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "eliasstravik";
    repo = "herdr-projects";
    rev = "v${version}";
    hash = "sha256-k9YRZaH7GG2EbTjC2f7c3jXlZgOnd0/9eirzIa5+hUo=";
  };

  cargoHash = "sha256-/fctXfPuGxl/IcF/eBlqo6A0Z6XV5rEBDfuYaj2odUA=";

  doCheck = false;

  postInstall = ''
    mkdir -p $out/target/release
    cp -r $src/. $out/
    ln -s $out/bin/herdr-projects $out/target/release/herdr-projects
  '';

  passthru.herdrPlugin = {
    id = "herdr-projects";
    name = "Projects";
    minHerdrVersion = "0.9.1";
  };

  meta = {
    description = "Coordinator conversation, parallel worker threads and shared memory for herdr";
    homepage = "https://github.com/eliasstravik/herdr-projects";
    license = lib.licenses.mit;
    mainProgram = "herdr-projects";
  };
}
