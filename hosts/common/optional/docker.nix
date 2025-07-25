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
    # users.extraGroups.docker.members = ["username-with-access-to-socket"];
    # users.users.klowdo.extraGroups = ["docker"];
    networking.firewall.checkReversePath = "loose";
    virtualisation = {
      docker = {
        # enable = true;
        # extraOptions = "--bip=192.168.100.1/24";
        rootless = {
          # extraOptions = "--bip=192.168.100.1/24";
          enable = true;
          setSocketVariable = true;
          #
          daemon.settings = {
            dns = [
              "8.8.8.8"
              "1.1.1.1"
              "10.244.0.15"
              "10.244.0.20"
            ];
            # bip = "192.168.100.1/24";
            # fixed-cidr": "192.168.1.0/25",
            # "mtu": 1500,
            # network-mode = "vpnkit"; # default-gateway = "192.168.100.254";
          };
        };
        # daemon.settings = {
        #   dns = ["8.8.8.8" "1.1.1.1"];
        #   # # fixed-cidr = "182.168.1.0/25";
        #   bip = "172.168.2.1/24";
        #   # # fixed-cidr": "192.168.1.0/25",
        #   # # "mtu": 1500,
        #   # default-gateway = "172.168.2.254";
        # };
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

    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = "1";
    };

    environment.systemPackages = with pkgs; [
      unstable.lazydocker
      unstable.dive
      slirp4netns
      fuse-overlayfs
    ];
  };
}
