{
  flake.modules.nixos.strongswan-swanctl = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) concatStringsSep;
    connectionName = "worldstream";
    homedns = "192.168.10.1";

    localSubnetOctets = [10 20 30 31 50 60 70 80 90 100 110 120 254];
    localSubnets = map (octet: "192.168.${toString octet}.0/24") localSubnetOctets;

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

    shellsScript =
      pkgs.writeShellScriptBin "ws-vpn-swanctl"
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

          MANUAL_DNS=''${MANUAL_DNS:-true}

          if [ "$MANUAL_DNS" = true ]; then
            echo "Manually setting DNS (override mode)"
            for INT in "''${INTERFACES[@]}"; do
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
    config = {
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

      services.strongswan-swanctl = {
        enable = true;

        strongswan.extraConfig = ''
          charon {
            plugins {
              resolve {
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

        includes = [
          config.sops.secrets."strong-swan.swanctl-secrets".path
        ];

        swanctl = {
          connections = {
            "${connectionName}" = {
              version = 1;
              aggressive = true;

              proposals = ["aes256-sha256-modp2048"];

              remote_addrs = ["vpn-nldw.worldstream.net"];

              vips = ["0.0.0.0"];

              rekey_time = "28620s";

              local."1" = {
                auth = "psk";
                id = "@10";
              };

              local."2" = {
                auth = "xauth";
                id = "@10";
                xauth_id = "felix.svensson@nl.worldstream.com";
              };

              remote."1" = {
                auth = "psk";
                id = "%any";
              };

              children = {
                "${connectionName}" = {
                  esp_proposals = ["aes256-sha256-modp2048"];

                  local_ts = ["dynamic"];
                  remote_ts = ["0.0.0.0/0"];

                  rekey_time = "43020s";

                  mode = "tunnel";

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
              };
            };
          };
        };
      };
    };
  };
}
