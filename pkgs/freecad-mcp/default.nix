# nix-update: freecad-mcp
{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "freecad-mcp";
  version = "0.1.19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "neka-nat";
    repo = "freecad-mcp";
    rev = "0a6ba35c6a4c8a43750610d68c1e8f43ac0cf422";
    hash = "sha256-Xfl5uA0iGbJ8srNM80PwbVVw1mJSfHyys7rzqyeiOQg=";
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
