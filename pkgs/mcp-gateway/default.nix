{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mcp-gateway";
  version = "unstable-2026-01-21";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "mcp-gateway";
    rev = "1b8ff5774ce689941cd7e65591950180a7d45043";
    hash = "sha256-fi7rL/s5P/7KaSSA7K5fRKmnqf4xx/uFLCju6YKJLic=";
  };

  vendorHash = null;

  subPackages = ["cmd/docker-mcp"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/docker/mcp-gateway/cmd/docker/version.Version=v${version}"
  ];

  installPhase = ''
    runHook preInstall

    install -D $GOPATH/bin/docker-mcp $out/libexec/docker/cli-plugins/docker-mcp

    mkdir -p $out/bin
    ln -s $out/libexec/docker/cli-plugins/docker-mcp $out/bin/docker-mcp

    runHook postInstall
  '';

  meta = with lib; {
    description = "Docker MCP Gateway - CLI plugin for managing Model Context Protocol servers";
    longDescription = ''
      Docker MCP Gateway is a CLI plugin for Docker that manages MCP (Model Context Protocol)
      servers. It acts as a gateway allowing AI applications to connect to external data sources
      and tools through the standardized MCP protocol.

      The plugin enables secure access to various services and APIs through Docker containers,
      with support for secret management and OAuth authentication flows.
    '';
    homepage = "https://github.com/docker/mcp-gateway";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [];
    mainProgram = "docker-mcp";
  };
}
