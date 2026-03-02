{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.strongSwan-swanctl;
  connectionName = "worldstream";
  homedns = "192.168.10.1";

  # Local subnets to bypass VPN - third octets
  localSubnetOctets = [10 20 30 31 50 60 70 80 90 100 110 120 254];
  localSubnets = map (octet: "192.168.${toString octet}.0/24") localSubnetOctets;

  # Shell script for toggling VPN (for GUI button)
  toggleScript = pkgs.writeShellScriptBin "ws-vpn-toggle" ''
    #!/usr/bin/env bash
    if ${pkgs.strongswan}/bin/swanctl --list-sas 2>/dev/null | grep -q 'ESTABLISHED'; then
      echo "Disconnecting VPN..."
      ws-vpn-swanctl down
    else
      echo "Connecting VPN..."
      ws-vpn-swanctl up
    fi
  '';

  # Shell script for managing VPN connection
  shellsScript =
    pkgs.writeShellScriptBin "ws-vpn-swanctl"
    # shell
    ''
      INTERFACES=("enp0s20f0u1u1" "wlp0s20f3")
      HOMEDNS=${homedns}
      PUBLICDNS="1.1.1.1"
      DNS1=10.10.16.10
      DNS2=10.10.17.10

      if [ "$1" == 'up' ]; then
        tailscale_status=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq .BackendState -r)
        if [ "$tailscale_status" == 'Running' ]; then
          ${pkgs.tailscale}/bin/tailscale down
        fi
        ${pkgs.strongswan}/bin/swanctl --initiate --child ${connectionName}

        # Note: DNS should be automatically configured by strongSwan via resolvectl
        # The manual DNS configuration below is kept as a fallback/override
        # Set MANUAL_DNS=false to rely on strongSwan's automatic DNS
        MANUAL_DNS=''${MANUAL_DNS:-true}

        if [ "$MANUAL_DNS" = true ]; then
          echo "Manually setting DNS (override mode)"
          for INT in "''${INTERFACES[@]}"; do
            # Check if interface exists
            if ip link show "$INT" &>/dev/null; then
              echo "Setting DNS for interface $INT"
              sudo resolvectl dns "$INT" "$DNS1" "$DNS2"
            else
              echo "Interface $INT is not available, skipping"
            fi
          done
        else
          echo "DNS automatically configured by strongSwan"
        fi

      elif [ "$1" == 'down' ]; then
        ${pkgs.strongswan}/bin/swanctl --terminate --ike ${connectionName}

        for INT in "''${INTERFACES[@]}"; do
          # Check if interface exists
          if ip link show "$INT" &>/dev/null; then
            echo "Setting HOME DNS for interface $INT"
            sudo resolvectl dns "$INT" "$HOMEDNS" "$PUBLICDNS"
          else
            echo "Interface $INT is not available, skipping"
          fi
        done

        ${pkgs.tailscale}/bin/tailscale up

      elif [ "$1" == 'rdns' ]; then
        for INT in "''${INTERFACES[@]}"; do
          # Check if interface exists
          if ip link show "$INT" &>/dev/null; then
            echo "Setting DNS for interface $INT"
            sudo resolvectl dns "$INT" "$DNS1" "$DNS2"
          else
            echo "Interface $INT is not available, skipping"
          fi
        done

      elif [ "$1" == 'status' ]; then
        ${pkgs.strongswan}/bin/swanctl --list-sas

      else
        echo "Usage: ws-vpn-swanctl {up|down|rdns|status}"
        exit 1
      fi
    '';
in {
  options.extraServices.strongSwan-swanctl.enable = mkEnableOption "enable strongSwan VPN client using swanctl";

  config = mkIf cfg.enable {
    # SOPS secrets configuration
    sops.secrets."strong-swan.swanctl-secrets" = {
      mode = "0600";
      owner = "root";
    };

    environment.systemPackages = [
      pkgs.strongswan
      shellsScript
      toggleScript
    ];

    networking.networkmanager.plugins = [
      pkgs.networkmanager-strongswan
    ];

    # Configure strongswan.conf to disable DNS installation via resolvconf
    # This properly fixes the "resolvconf is disabled" errors
    services.strongswan-swanctl = {
      enable = true;

      # Configure strongswan.conf to use resolvectl for DNS
      strongswan.extraConfig = ''
        charon {
          # Configure DNS installation via resolvectl (systemd-resolved)
          plugins {
            resolve {
              # Use resolvectl instead of legacy resolvconf
              resolvconf = resolvectl
            }
            bypass-lan {
              load = yes
              subnets_include = ${concatStringsSep ", " localSubnets}
              interfaces_ignore = tailscale0
            }
          }
        }
      '';

      # Include SOPS-managed secrets file
      includes = [
        config.sops.secrets."strong-swan.swanctl-secrets".path
      ];

      swanctl = {
        connections = {
          "${connectionName}" = {
            # IKEv1 with Aggressive Mode
            version = 1;
            aggressive = true;

            # IKE proposals
            proposals = ["aes256-sha256-modp2048"];

            # Remote endpoint
            remote_addrs = ["vpn-nldw.worldstream.net"];

            # Request virtual IP
            vips = ["0.0.0.0"];

            # Rekey times (calculated as lifetime - margin)
            # ikelifetime = 28800s, margin = 3m (180s) → rekey at 28620s
            rekey_time = "28620s";

            # First authentication round: PSK
            local."1" = {
              auth = "psk";
              id = "@10";
            };

            # Second authentication round: XAuth
            local."2" = {
              auth = "xauth";
              id = "@10";
              xauth_id = "felix.svensson@nl.worldstream.com";
            };

            # Remote authentication
            remote."1" = {
              auth = "psk";
              id = "%any";
            };

            # Child SA configuration
            children = {
              "${connectionName}" = {
                # ESP proposals
                esp_proposals = ["aes256-sha256-modp2048"];

                # Traffic selectors
                local_ts = ["dynamic"];
                remote_ts = ["0.0.0.0/0"];

                # Rekey time (keylife = 12h = 43200s, margin = 3m = 180s)
                rekey_time = "43020s";

                # Mode
                mode = "tunnel";

                # DPD action
                dpd_action = "restart";
                updown = "${pkgs.writeShellScript "vpn-updown" ''
                  case "$PLUTO_VERB" in
                    up-client)
                      for net in ${concatStringsSep " " localSubnets}; do
                        ip xfrm policy add src 0.0.0.0/0 dst $net dir out priority 100 2>/dev/null || true
                        ip xfrm policy add src $net dst 0.0.0.0/0 dir in priority 100 2>/dev/null || true
                        ip route add throw $net table 220 2>/dev/null || true
                      done
                      ;;
                    down-client)
                      for net in ${concatStringsSep " " localSubnets}; do
                        ip xfrm policy del src 0.0.0.0/0 dst $net dir out priority 100 2>/dev/null || true
                        ip xfrm policy del src $net dst 0.0.0.0/0 dir in priority 100 2>/dev/null || true
                        ip route del throw $net table 220 2>/dev/null || true
                      done
                      ;;
                  esac
                ''}";
              };

              # "local-bypass" = {
              #   local_ts = ["dynamic"];
              #   remote_ts = [
              #     "192.168.10.0/24" # Default
              #     "192.168.20.0/24" # Guest
              #     "192.168.30.0/24" # IoT
              #     "192.168.31.0/24" # IoT Local
              #     "192.168.50.0/24" # Felix
              #     "192.168.60.0/24" # Emma
              #     "192.168.70.0/24" # HA
              #     "192.168.80.0/24" # Services
              #     "192.168.90.0/24" # Cast
              #     "192.168.100.0/24" # TV
              #     "192.168.110.0/24" # Appliances
              #     "192.168.120.0/24" # Bambu
              #     "192.168.254.0/24" # Management
              #   ];
              #   mode = "pass";

              #   start_action = trap
              # };
            };
          };
        };
        # passthrough-subnet = {
        #   remote_addrs = "127.0.0.1";
        #   children = {
        #     passthrough-subnet = {
        #       local_ts = "10.1.0.0/24";
        #       remote_ts = "192.168.2.0/24";
        #       mode = "pass";
        #       start_action = "trap";
        #     };
        #   };
        # };
      };
    };
  };
}
