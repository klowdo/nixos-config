# nix-update: herdr-sesh
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "herdr-sesh";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "fullerzz";
    repo = "herdr-plugin-sesh";
    rev = "v${version}";
    hash = "sha256-Rm2BGvAW/D0iNr3RXpcRcQkkLO/Wor48CJ0BhduW35M=";
  };

  vendorHash = "sha256-WfgGf5bTsspAmMii9FdCQCuCuTCPt6aIt8S5B6AMDvs=";

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
