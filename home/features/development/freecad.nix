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
  in {
    home.packages = [
      pkgs.unstable.freecad-wayland
      pkgs.freecad-mcp
    ];

    home.shellAliases.claude-freecad = "claude --mcp-config ${freecadMcpConfig}";

    xdg.dataFile."FreeCAD/v1-1/Mod/FreeCADMCP".source = "${pkgs.freecad-mcp.src}/addon/FreeCADMCP";
  });
}
