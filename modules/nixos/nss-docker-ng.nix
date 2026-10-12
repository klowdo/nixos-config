{
  flake.modules.nixos.nss-docker-ng = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types mkIf mkMerge mkAfter;
    cfg = config.extraServices.nss-docker-ng;
  in {
    options.extraServices.nss-docker-ng = {
      position = mkOption {
        type = types.enum ["before-dns" "after-dns"];
        default = "before-dns";
        description = ''
          Position of docker_ng in the NSS hosts database.

          - "before-dns": Place docker_ng before DNS resolution (recommended for .docker domains)
          - "after-dns": Place docker_ng after DNS resolution (fallback mode)

          The hosts line will look like:
          - before-dns: hosts: files mymachines docker_ng resolve [!UNAVAIL=return] dns myhostname
          - after-dns: hosts: files mymachines resolve [!UNAVAIL=return] dns docker_ng myhostname
        '';
      };

      dockerHost = mkOption {
        type = types.str;
        default = "unix:///var/run/docker.sock";
        example = "unix:///run/user/1000/docker.sock";
        description = ''
          Docker socket path for the NSS module to connect to.

          Common values:
          - unix:///var/run/docker.sock (default, rootful Docker)
          - unix:///run/user/1000/docker.sock (rootless Docker)
          - tcp://localhost:2375 (TCP connection)

          This sets the DOCKER_HOST environment variable system-wide so NSS
          modules loaded by system processes can connect to Docker.
        '';
      };
    };

    config = {
      system.nssModules = [pkgs.nss-docker-ng];

      system.nssDatabases.hosts = mkMerge [
        (mkIf (cfg.position == "before-dns") ["docker_ng"])
        (mkIf (cfg.position == "after-dns") (mkAfter ["docker_ng"]))
      ];

      environment.variables.DOCKER_HOST = cfg.dockerHost;

      systemd.globalEnvironment.DOCKER_HOST = cfg.dockerHost;

      warnings = mkIf (cfg.position == "after-dns") [
        ''
          nss-docker-ng is configured in "after-dns" mode. This means Docker container
          hostnames will only be resolved if DNS fails to resolve them. Consider using
          "before-dns" mode for better .docker domain resolution.
        ''
      ];
    };
  };
}
