{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.podman;
in {
  options.extraServices.podman.enable = mkEnableOption "enable podman";

  # dive = "docker run -ti --rm  -v /run/user/1000/podman/podman.sock:/var/run/docker.sock wagoodman/dive";
  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [
            "--filter=until=24h"
            "--filter=label!=important"
          ];
        };
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.variables = {
      DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
    };

    environment.systemPackages = with pkgs; [
      podman-compose
      lazydocker
      podman-desktop
    ];
  };
}
