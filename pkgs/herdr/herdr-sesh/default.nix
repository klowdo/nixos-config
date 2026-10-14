# nix-update: herdr-sesh
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "herdr-sesh";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "fullerzz";
    repo = "herdr-plugin-sesh";
    rev = "v${version}";
    hash = "sha256-sHqlqQWoPWOJTVBlEvV6js0Wwk6ehMoa6uJx07Cg0+g=";
  };

  vendorHash = "sha256-3v8D4Gblg/4REwiYCCPaDete8K+6ngzvdWnfJjbQ+O4=";

  subPackages = ["cmd/herdr-sesh"];

  ldflags = ["-X=github.com/fullerzz/herdr-plugin-sesh/internal/app.Version=${version}"];

  doCheck = false;

  postInstall = ''
    cp -r --no-preserve=mode ${src}/. $out
    chmod +x $out/bin/herdr-sesh
  '';

  passthru.herdrPlugin = {
    id = "fullerzz.sesh";
    name = "Sesh for Herdr";
    minHerdrVersion = "0.8.2";
  };

  meta = {
    description = "Sesh-style workspace picker and session manager for herdr";
    homepage = "https://github.com/fullerzz/herdr-plugin-sesh";
    license = lib.licenses.mit;
    mainProgram = "herdr-sesh";
  };
}
