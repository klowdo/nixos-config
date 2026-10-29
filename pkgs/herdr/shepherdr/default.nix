# nix-update: shepherdr
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  agent-browser,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shepherdr";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "eliasstravik";
    repo = "shepherdr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rrbPCWQ6K4tHr+Sy22wol3J8CobRpORUaMyUhrBp6O4=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;
    nativeBuildInputs = [bun];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      bun install --frozen-lockfile --ignore-scripts --no-progress
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -r node_modules $out
      runHook postInstall
    '';
    dontFixup = true;
    outputHash = "sha256-LwSHP/40XCUBW6cllQPvuR2wQf1kytBq4ZKsp9Ig4dQ=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [bun];

  postPatch = ''
    sed -i '/^\[\[build\]\]/,/^$/d' herdr-plugin.toml
    substituteInPlace herdr-plugin.toml --replace-fail '"sh", "scripts/need-bun.sh"' '"${lib.getExe bun}"'
    substituteInPlace bin/shepherdr --replace-fail 'exec bun ' 'exec ${lib.getExe bun} '
    substituteInPlace bin/shepherdr bin/agent-browser --replace-fail 'here=$(cd "$(dirname "$0")/.." && pwd)' "here=$out"
    substituteInPlace bin/agent-browser --replace-fail 'b="$here/node_modules/agent-browser/bin/agent-browser-$os$musl-$arch"' 'b=${lib.getExe agent-browser}'
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    cp -r ${finalAttrs.node_modules} node_modules
    chmod -R u+w node_modules
    bun scripts/build-plugins.ts
    bun node_modules/vite/bin/vite.js build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  passthru.herdrPlugin = {
    id = "herdr-projects";
    name = "Shepherdr";
    minHerdrVersion = "0.9.0";
  };

  meta = {
    description = "Run many coding agents across machines from a phone, tablet or desktop";
    homepage = "https://github.com/eliasstravik/shepherdr";
    license = lib.licenses.mit;
    mainProgram = "shepherdr";
  };
})
