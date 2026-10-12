# mcp-gateway's Makefile installs the binary as $HOME/.docker/cli-plugins/docker-mcp,
# so the plugin is linked there explicitly.
{...}: {
  flake.modules.homeManager.mcp-gateway = {
    lib,
    pkgs,
    ...
  }: {
    home = {
      file.".docker/cli-plugins/docker-mcp".source = lib.getExe pkgs.mcp-gateway;
      packages = [
        pkgs.mcp-gateway
      ];

      sessionVariables = {
        DOCKER_MCP_IN_CONTAINER = 1;
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
