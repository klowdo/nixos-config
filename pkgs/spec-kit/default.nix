# nix-update: spec-kit
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "specify-cli";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    tag = "v${version}";
    hash = "sha256-S2XC7i9Nljzd0/E4J2ks+89CIEOQMArqLQDCvsxp93U=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    typer
    rich
    httpx
    platformdirs
    readchar
    truststore
    pyyaml
    packaging
  ];

  pythonImportsCheck = ["specify_cli"];

  meta = {
    description = "Specify CLI - bootstrap projects for Spec-Driven Development";
    homepage = "https://github.com/github/spec-kit";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "specify";
  };
}
