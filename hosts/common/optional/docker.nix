{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.docker;
in {
  options.extraServices.docker.enable = mkEnableOption "enable docker";

  config = mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
        daemon.settings = {
          dns = ["8.8.8.8" "1.1.1.1"];
        };
        autoPrune = {
          enable = true;
          dates = "daily";
          flags = [
            "--all"
            "--filter=until=24h"
            "--filter=label!=important"
          ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      unstable.lazydocker
    ];
  };
}
