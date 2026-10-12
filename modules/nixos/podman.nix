{
  flake.modules.nixos.podman = {pkgs, ...}: {
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
