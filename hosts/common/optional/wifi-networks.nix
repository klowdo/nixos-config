{
  config,
  lib,
  ...
}: let
  cfg = config.wifi;

  mkNetworkManagerProfile = name: network: ''
    [connection]
    id=${name}
    type=wifi
    autoconnect=${
      if network.autoconnect
      then "true"
      else "false"
    }

    [wifi]
    mode=infrastructure
    ssid=${network.ssid}

    [wifi-security]
    key-mgmt=wpa-psk
    psk=${network.pskPlaceholder}

    [ipv4]
    method=auto

    [ipv6]
    method=auto
  '';
in {
  options.wifi = {
    enable = lib.mkEnableOption "declarative WiFi networks via SOPS";

    networks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          ssid = lib.mkOption {
            type = lib.types.str;
            description = "WiFi network SSID";
          };

          sopsKey = lib.mkOption {
            type = lib.types.str;
            description = "Key path in secrets.yaml for the PSK (e.g., 'wifi/home')";
          };

          autoconnect = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to automatically connect to this network";
          };
        };
      });
      default = {};
      description = "WiFi networks to configure";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.mapAttrs' (name: network:
      lib.nameValuePair "wifi-${name}" {
        sopsFile = ../../../secrets.yaml;
        key = network.sopsKey;
      })
    cfg.networks;

    sops.templates = lib.mapAttrs' (name: network:
      lib.nameValuePair "wifi-${name}.nmconnection" {
        content = mkNetworkManagerProfile name (network
          // {
            pskPlaceholder = config.sops.placeholder."wifi-${name}";
          });
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/etc/NetworkManager/system-connections/${name}.nmconnection";
      })
    cfg.networks;

    systemd.services.NetworkManager = {
      wants = lib.mapAttrsToList (name: _: "sops-nix.service") cfg.networks;
      after = lib.mapAttrsToList (name: _: "sops-nix.service") cfg.networks;
    };
  };
}
