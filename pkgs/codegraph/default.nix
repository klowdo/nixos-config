# nix-update: codegraph
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  typescript,
}:
buildNpmPackage rec {
  pname = "codegraph";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    tag = "v${version}";
    hash = "sha256-0rMaBdqPeHJDlTAOyYvpxxNPEWbO75y5oKQZ3Dr5DHE=";
  };

  npmDepsHash = "sha256-xD2Mz5DWsiVxSDwEGW7KqqR8A7Pn4SLbip+ITfoHkBM=";

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
