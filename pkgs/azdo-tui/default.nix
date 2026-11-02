# nix-update: azdo-tui
{
  fetchurl,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "azdo-tui";
  version = "0.8.5";

  src = fetchurl {
    url = "https://github.com/Elpulgo/azdo/releases/download/v${version}/azdo_${version}_Darwin_arm64.tar.gz";
    hash = "sha256-Gl1Gi/hRCHSHUWZR8UJRK2qzb+i1e1tGJUeNrIbW9FQ=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 azdo $out/bin/azdo
    runHook postInstall
  '';

  meta = {
    description = "Terminal UI for Azure DevOps and GitHub";
    homepage = "https://github.com/Elpulgo/azdo";
    license = lib.licenses.mit;
    platforms = ["aarch64-darwin"];
    mainProgram = "azdo";
  };
}
