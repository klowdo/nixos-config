{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.freecad;
in {
  options.features.development.freecad.enable = mkEnableOption "enable freecad";

  config = mkIf cfg.enable (let
    # ponytail: coin3d vendors expat 2.2.10 and exports its XML_* symbols, which
    # interpose over libexpat 2.8.2 and segfault python's _elementtree.
    # nixpkgs#544607 — drop this wrapper once coin3d builds with USE_EXTERNAL_EXPAT.
    freecad = pkgs.unstable.symlinkJoin {
      name = "freecad-wayland-expat-fix";
      paths = [pkgs.unstable.freecad-wayland];
      nativeBuildInputs = [pkgs.unstable.makeWrapper];
      postBuild = ''
        for bin in FreeCAD FreeCADCmd freecad freecadcmd; do
          wrapProgram $out/bin/$bin \
            --set LD_PRELOAD ${pkgs.unstable.expat}/lib/libexpat.so.1
        done
      '';
    };

    freecadMcpConfig = pkgs.writeText "freecad-mcp.json" (builtins.toJSON {
      mcpServers.freecad = {
        command = "${pkgs.freecad-mcp}/bin/freecad-mcp";
        args = ["--only-text-feedback"];
      };
    });
    freecadSettings = pkgs.writeText "freecad-settings.json" (builtins.toJSON {
      autoMode = {
        allow = [
          "$defaults"
          "All FreeCAD MCP tools are allowed: creating, editing, deleting objects, executing code, getting views, running FEM analysis, and managing documents in the local FreeCAD instance via XML-RPC"
        ];
      };
    });
  in {
    home.packages = [
      freecad
      pkgs.freecad-mcp
    ];

    home.shellAliases.claude-freecad = "claude --mcp-config ${freecadMcpConfig} --settings ${freecadSettings}";

    xdg.dataFile."FreeCAD/v1-1/Mod/FreeCADMCP".source = "${pkgs.freecad-mcp.src}/addon/FreeCADMCP";
  });
}
