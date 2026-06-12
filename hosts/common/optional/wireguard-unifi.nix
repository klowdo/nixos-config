{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.wireguard-unifi;
  confPath = "/etc/wireguard/${cfg.interface}.conf";
in {
  options.extraServices.wireguard-unifi = {
    enable = mkEnableOption "UniFi WireGuard VPN client (manual toggle)";
    interface = mkOption {
      type = types.str;
      default = "unifi";
      description = "wg-quick interface name";
    };
    address = mkOption {
      type = types.listOf types.str;
      description = "Client tunnel address(es) from the UniFi .conf (private)";
    };
    dns = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "DNS servers pushed through the tunnel";
    };
    peerPublicKey = mkOption {
      type = types.str;
      description = "UniFi VPN server public key (not secret)";
    };
    allowedIPs = mkOption {
      type = types.listOf types.str;
      default = [
        "0.0.0.0/0"
        "::/0"
      ];
      description = "Routed networks; default = full tunnel";
    };
    usePresharedKey = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the UniFi config includes a preshared key";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets =
      {
        "wireguard/unifi/private-key" = {};
        "wireguard/unifi/endpoint" = {};
      }
      // optionalAttrs cfg.usePresharedKey {
        "wireguard/unifi/preshared-key" = {};
      };

    sops.templates."wg-${cfg.interface}.conf" = {
      mode = "0600";
      path = confPath;
      content = ''
        [Interface]
        PrivateKey = ${config.sops.placeholder."wireguard/unifi/private-key"}
        Address = ${concatStringsSep ", " cfg.address}
        ${optionalString (cfg.dns != []) "DNS = ${concatStringsSep ", " cfg.dns}"}

        [Peer]
        PublicKey = ${cfg.peerPublicKey}
        ${optionalString cfg.usePresharedKey "PresharedKey = ${
          config.sops.placeholder."wireguard/unifi/preshared-key"
        }"}
        AllowedIPs = ${concatStringsSep ", " cfg.allowedIPs}
        Endpoint = ${config.sops.placeholder."wireguard/unifi/endpoint"}
        PersistentKeepalive = 25
      '';
    };

    environment.systemPackages = [pkgs.wireguard-tools];

    systemd.services."wg-quick-${cfg.interface}" = {
      description = "WireGuard tunnel ${cfg.interface} (UniFi)";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      path = with pkgs; [
        wireguard-tools
        iproute2
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up ${confPath}";
        ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down ${confPath}";
      };
    };
  };
}
