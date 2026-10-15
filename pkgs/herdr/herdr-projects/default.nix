# nix-update: herdr-projects
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-projects";
  version = "0.2.34";

  src = fetchFromGitHub {
    owner = "eliasstravik";
    repo = "herdr-projects";
    rev = "v${version}";
    hash = "sha256-3Pmg0yDPFRY8fWI3Qc/0oMxnbFTBTHM48C38v63wFP4=";
  };

  cargoHash = "sha256-VOOKjB1M731OscdDE3XOadDU25rC+yyxBP/IAovL6rg=";

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
