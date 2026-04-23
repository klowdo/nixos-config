{pkgs, ...}: {
  home.file = {
    ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
    ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";
  };
}
