# nix-update: kanzo
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kanzo";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/emanuele-em/kanzo/releases/download/v${finalAttrs.version}/kanzo-x86_64-unknown-linux-musl.tar.xz";
    hash = "sha256-FGwk6TyUMVj66P418HD0lBSh9HVIMjEjYduoldPL7+o=";
  };

  installPhase = ''
    install -Dm755 kanzo $out/bin/kanzo
  '';

  meta = {
    description = "Self-hosted kanban board and MCP server for humans and agents";
    homepage = "https://github.com/emanuele-em/kanzo";
    license = lib.licenses.agpl3Only;
    mainProgram = "kanzo";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
