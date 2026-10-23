# nix-update: herdr-projects
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-projects";
  version = "1.2.23";

  src = fetchFromGitHub {
    owner = "eliasstravik";
    repo = "herdr-projects";
    rev = "v${version}";
    hash = "sha256-e/+gT6cuXpPvVxBvArHXGLW7VP4k71q81gTj2XJnSUI=";
  };

  cargoHash = "sha256-x8k4KwkcjbHuYHSQcSQ2R7EGB1NUGWD2RPVEEc3Al04=";

  doCheck = false;

  postInstall = ''
    mkdir -p $out/target/release
    cp -r $src/. $out/
    ln -s $out/bin/herdr-projects $out/target/release/herdr-projects
  '';

  passthru.herdrPlugin = {
    id = "herdr-projects";
    name = "Projects";
    minHerdrVersion = "0.9.3";
  };

  meta = {
    description = "A work board for herdr: one list of tasks, each delegated one an ordinary herdr agent";
    homepage = "https://github.com/eliasstravik/herdr-projects";
    license = lib.licenses.mit;
    mainProgram = "herdr-projects";
  };
}
