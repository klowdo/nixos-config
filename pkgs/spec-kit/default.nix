{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication {
  pname = "specify-cli";
  version = "0.0.101";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    tag = "v0.0.101";
    hash = "sha256-725CZPE2QNzFXnYCX8i+HGSDyYnTXm9rMoNtesEgphM=";
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
