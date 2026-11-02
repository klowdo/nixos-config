# nix-update: vim-herdr-navigation --version=branch
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "vim-herdr-navigation";
  version = "0.1.0-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "paulbkim-dev";
    repo = "vim-herdr-navigation";
    rev = "7873100eb47212269005c693effb2a844986b30f";
    hash = "sha256-clp3xPU7FfcfDookBI2SDSFQLygWke3gaG0RH2T7Jy0=";
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
