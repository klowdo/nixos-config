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

  # looking at https://github.com/docker/mcp-gateway/blob/main/Makefile it installs it
  #    as $HOME/.docker/cli-plugins/docker-mcp is that handled somehere?
  config = mkIf cfg.enable {
    home = {
      file.".docker/cli-plugins/docker-mcp".source = lib.getExe pkgs.mcp-gateway;
      packages = [
        pkgs.mcp-gateway
      ];

      sessionVariables = {
        DOCKER_MCP_IN_CONTAINER = 1;
        CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
      };
    };

    programs.claude-code.mcpServers = {
      MCP_DOCKER = {
        command = "docker";
        args = [
          "mcp"
          "gateway"
          "run"
          "--secrets"
          "/run/secrets/mcp_secret:/.env"
        ];
        env = {
          DOCKER_HOST = "unix:///run/user/1000/docker.sock";
        };
      };
    };
  };
}
