# nix-update: herdr-projects
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-projects";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "eliasstravik";
    repo = "herdr-projects";
    rev = "v${version}";
    hash = "sha256-yqvlbCgyx2E70EVqAYtoGpZJx496MmMSiOWJAxsBQfI=";
  };

  cargoHash = "sha256-8G+6Qnt/sfqnkOSWBsW17glDzLlSwVX+KhNvgLS1RfI=";

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
