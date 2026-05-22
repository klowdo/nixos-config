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
      pkgs.unstable.freecad-wayland
      pkgs.freecad-mcp
    ];

    home.shellAliases.claude-freecad = "claude --mcp-config ${freecadMcpConfig} --settings ${freecadSettings}";

    xdg.dataFile."FreeCAD/v1-1/Mod/FreeCADMCP".source = "${pkgs.freecad-mcp.src}/addon/FreeCADMCP";
  });
}
