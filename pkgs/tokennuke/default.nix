{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "tokennuke";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "BigJai";
    repo = "tokennuke";
    rev = "b86a4c545a68111b75fc1fef4d4f512dd999a3c6";
    hash = "sha256-G0fPfW7TSnpUflgs+eDvrwxdh50/uCiW5nwkSNhlRDQ=";
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    mcp
    tree-sitter-language-pack
    httpx
    fastembed
    sqlite-vec
    pathspec
  ];

  pythonImportsCheck = ["tokennuke"];

  meta = {
    description = "Intelligent code indexing MCP server";
    homepage = "https://github.com/BigJai/tokennuke";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "tokennuke";
  };
}
