{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
}: let
  herdrAnnotateBin = fetchurl {
    url = "https://github.com/plannotator/herdr-annotate/releases/download/rust-lite-v0.2.0/herdr-annotate-x86_64-unknown-linux-gnu";
    hash = "sha256-o+9OcnhLuoz3nlgtYCHKNPDWAPFw2jCVvMYKh7G8uUI=";
  };
  plannotatorTuiBin = fetchurl {
    url = "https://github.com/plannotator/plannotator-tui/releases/download/v0.9.4/plannotator-tui-x86_64-unknown-linux-gnu";
    hash = "sha256-1U3GA8lfcQZ3vBPr5rJLLm6xDOdhV3r4qVoFAChit00=";
  };
in
  stdenv.mkDerivation {
    pname = "herdr-annotate";
    version = "0.9.1-unstable-2026-10-12";

    src = fetchFromGitHub {
      owner = "plannotator";
      repo = "herdr-annotate";
      rev = "ceab050b77bea07bbeabdfda5c138be8c9c5c517";
      hash = "sha256-Q/HgVn1gEAMMavWDQp8Rmz7R7qK5u0QweLkcpYL+otE=";
    };

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib];

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      cp -r . $out
      install -Dm755 ${herdrAnnotateBin} $out/bin/herdr-annotate.exe
      install -Dm755 ${plannotatorTuiBin} $out/bin/plannotator-tui.exe
      runHook postInstall
    '';

    passthru.herdrPlugin = {
      id = "annotate";
      name = "Annotate";
      minHerdrVersion = "0.8.0";
    };

    meta = {
      description = "Comment on terminal selections and review agent output in herdr";
      homepage = "https://github.com/plannotator/herdr-annotate";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
    };
  }
