# nix-update: spec-kit
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "specify-cli";
  version = "0.7.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    tag = "v${version}";
    hash = "sha256-eFr6IeQ0B5/zgVKyMo7Us2dcR9XsZ0SkrSD8c6Exs78=";
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
