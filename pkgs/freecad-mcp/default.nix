# nix-update: freecad-mcp
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "freecad-mcp";
  version = "0.1.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "neka-nat";
    repo = "freecad-mcp";
    rev = "8694c3214947efedfcf2423b3babad80af80d299";
    hash = "sha256-EYLr7FFIjrPmgngGvYJlQzRPEbYfvp84pIlCbazl/+8=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    mcp
    validators
  ];

  pythonImportsCheck = ["freecad_mcp"];

  meta = {
    description = "MCP server for FreeCAD - enables AI assistants to control FreeCAD via XML-RPC";
    homepage = "https://github.com/neka-nat/freecad-mcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "freecad-mcp";
  };
}
