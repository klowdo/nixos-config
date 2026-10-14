# nix-update: herdr-better-worktrees
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
}:
buildNpmPackage rec {
  pname = "herdr-better-worktrees";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "bearylabs";
    repo = "herdr-better-worktrees";
    rev = "v${version}";
    hash = "sha256-h5ZayKFkkIF54H3drpJp05oKvnPI8MExry45+/UNp+g=";
  };

  npmDepsHash = "sha256-8w1BE0DQtalniHGM8Xd4pl74vbwO7qF9wonVHid0kKU=";

  postPatch = ''
    substituteInPlace herdr-plugin.toml --replace-fail '"node"' '"${lib.getExe nodejs}"'
  '';

  installPhase = ''
    runHook preInstall
    rm -rf node_modules
    cp -r . $out
    runHook postInstall
  '';

  passthru.herdrPlugin = {
    id = "herdr-better-worktrees";
    name = "Herdr Better Worktrees";
    minHerdrVersion = "0.9.0";
  };

  meta = {
    description = "Manage embedded .bare Git worktrees from a herdr popup";
    homepage = "https://github.com/bearylabs/herdr-better-worktrees";
    license = lib.licenses.mit;
  };
}
