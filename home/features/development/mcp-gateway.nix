{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.mcp-gateway;
in {
  options.features.development.mcp-gateway.enable =
    mkEnableOption "enable mcp-gateway Docker CLI plugin with Claude Desktop integration";

  config = mkIf cfg.enable {
    programs.claude-code.mcpServers = {
      MCP_DOCKER = {
        command = "docker";
        args = [
          "mcp"
          "gateway"
          "run"
        ];
      };
    };
    home.packages = [
      pkgs.mcp-gateway
    ];

    home.sessionVariables = {
      CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
    };
  };
}
