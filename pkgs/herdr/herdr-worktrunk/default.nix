# nix-update: herdr-worktrunk
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "herdr-worktrunk";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "devashish2203";
    repo = "herdr-worktrunk";
    rev = "v${version}";
    hash = "sha256-Tx++zTQ1z4H8dLdCjOZ1yX9QGY/i6M3Yvi39KGHDoH4=";
  };

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  passthru.herdrPlugin = {
    id = "worktrunk";
    name = "Worktrunk";
    minHerdrVersion = "0.7.0";
  };

  meta = {
    description = "Switch, create, remove, or merge git worktrees via worktrunk in herdr";
    homepage = "https://github.com/devashish2203/herdr-worktrunk";
    license = lib.licenses.mit;
  };
}
