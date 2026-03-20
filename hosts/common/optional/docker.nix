{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.docker;
in {
  options.extraServices.docker = {
    enable = mkEnableOption "enable docker";
    usePasta = mkOption {
      type = types.bool;
      default = false;
      description = "Use pasta networking instead of slirp4netns (better performance)";
    };
    mtu = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "MTU for rootless docker networking (null = auto)";
    };
    stopContainersOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Stop all containers and reset restart policies after Docker starts on boot";
    };
  };

  config = mkIf cfg.enable {
    # users.extraGroups.docker.members = ["username-with-access-to-socket"];
    # users.users.klowdo.extraGroups = ["docker"];
    networking.firewall.checkReversePath = "loose";
    virtualisation = {
      docker = {
        # enable = true;
        # extraOptions = "--bip=192.168.100.1/24";
        rootless = {
          enable = true;
          setSocketVariable = true;
          extraPackages =
            if cfg.usePasta
            then [pkgs.passt]
            else [pkgs.slirp4netns];
          daemon.settings = {
            # dns = [
            #   "10.10.16.10"
            #   "10.10.17.10"
            #   "8.8.8.8"
            #   "1.1.1.1"
            # ];
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
            "--volumes"
            "--filter=until=24h"
            "--filter=label!=important"
          ];
        };
      };
    };

    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = "1";
    };
    systemd = {
      services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";
      user = {
        services.docker-buildx-prune = {
          description = "Prune Docker buildx cache";
          requires = ["docker.service"];
          after = ["docker.service"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.docker}/bin/docker buildx prune -f --filter=until=24h";
            Environment = "DOCKER_HOST=unix:///run/user/%U/docker.sock";
          };
        };

        timers.docker-buildx-prune = {
          description = "Prune Docker buildx cache";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "5min";
            OnCalendar = "*-*-* 09,12:00:00";
            Persistent = true;
          };
        };

        services.docker-stop-on-boot = mkIf cfg.stopContainersOnBoot {
          description = "Stop auto-started Docker containers on boot";
          requires = ["docker.service"];
          after = ["docker.service"];
          wantedBy = ["docker.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "docker-stop-on-boot" ''
              containers=$(${pkgs.docker}/bin/docker ps -aq)
              if [ -n "$containers" ]; then
                ${pkgs.docker}/bin/docker update --restart=no $containers
                ${pkgs.docker}/bin/docker stop $containers
              fi
            '';
            Environment = "DOCKER_HOST=unix:///run/user/%U/docker.sock";
          };
        };

        services.docker.environment =
          optionalAttrs cfg.usePasta {
            DOCKERD_ROOTLESS_ROOTLESSKIT_NET = "pasta";
          }
          // optionalAttrs (cfg.mtu != null) {
            DOCKERD_ROOTLESS_ROOTLESSKIT_MTU = toString cfg.mtu;
          };
      };
    };

    environment.systemPackages = with pkgs; [
      lazydocker
      unstable.dive
      fuse-overlayfs
    ];
  };
}
