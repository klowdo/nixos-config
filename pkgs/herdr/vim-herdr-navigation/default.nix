# nix-update: vim-herdr-navigation --version=branch
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "vim-herdr-navigation";
  version = "0.1.0-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "paulbkim-dev";
    repo = "vim-herdr-navigation";
    rev = "742db891e7d1f9a550b16c01dc8a6763f2b1493a";
    hash = "sha256-Yt82HBBOdY4tjvZVREpQzKoEklJY0aIYU5ZzISdf7fg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  passthru.herdrPlugin = {
    id = "vim-herdr-navigation";
    name = "Vim Herdr Navigation";
    minHerdrVersion = "0.7.0";
  };

  meta = {
    description = "Seamless Ctrl+h/j/k/l navigation across herdr panes and Vim splits";
    homepage = "https://github.com/paulbkim-dev/vim-herdr-navigation";
    license = lib.licenses.mit;
  };
}
