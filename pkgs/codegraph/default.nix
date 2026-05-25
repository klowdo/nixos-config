# nix-update: codegraph
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  typescript,
}:
buildNpmPackage rec {
  pname = "codegraph";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    tag = "v${version}";
    hash = "sha256-tJgpy1qyG7sSAIATTpVy9qgOoxf1K4J3dAh2xhTHgS8=";
  };

  npmDepsHash = "sha256-GJfqzykgrgD/KCtf8LupRw31S2cCmwGCF/0PMpzaCrk=";

  nativeBuildInputs = [typescript];

  postBuild = ''
    tsc
    mkdir -p dist/db dist/extraction/wasm
    cp src/db/schema.sql dist/db/schema.sql
    for f in src/extraction/wasm/*.wasm; do
      [ -f "$f" ] && cp "$f" dist/extraction/wasm/
    done
    chmod +x dist/bin/codegraph.js
  '';

  meta = {
    description = "Pre-indexed semantic code knowledge graph MCP server";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "codegraph";
  };
}
