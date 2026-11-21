# nix-update: codegraph
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  typescript,
}:
buildNpmPackage rec {
  pname = "codegraph";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    tag = "v${version}";
    hash = "sha256-V0Q/tivtO64vYkFOeWFXu1gGZCIAAtiT1Htz5xNkFns=";
  };

  npmDepsHash = "sha256-8Jj2u885Qsv/FOwxJbIovFWcMVkOQl2ata+CN1qs/m4=";

  nativeBuildInputs = [typescript];

  dontNpmBuild = true;

  postBuild = ''
    tsc
    mkdir -p dist/db dist/extraction/wasm
    cp src/db/schema.sql dist/db/schema.sql
    for f in src/extraction/wasm/*.wasm; do
      [ -f "$f" ] && cp "$f" dist/extraction/wasm/
    done
    chmod +x dist/bin/codegraph.js
  '';

  postInstall = ''
    rm -f "$out/lib/node_modules/@colbymchenry/codegraph/node_modules/@colbymchenry/codegraph-ui"
  '';

  meta = {
    description = "Pre-indexed semantic code knowledge graph MCP server";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "codegraph";
  };
}
