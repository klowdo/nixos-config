# nix-update: herdr-bar
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation rec {
  pname = "herdr-bar";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    rev = "v${version}";
    hash = "sha256-LILcta5y5EilQ5B6DKjYyWlwB2k88Kx1rTZXqv/uJhw=";
  };

  postPatch = ''
    substituteInPlace herdr-plugin.toml --replace-fail '"python3"' '"${lib.getExe python3}"'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
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
  };
}
