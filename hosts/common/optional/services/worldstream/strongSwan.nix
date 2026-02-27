{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.strongSwan;
  connecionName = "worldstream";
  homedns = "192.168.10.1";
  shellsScript =
    pkgs.writeShellScriptBin "ws-vpn"
    # shell
    ''
      INTERFACES=("enp0s20f0u1u1" "wlp0s20f3")
      HOMEDNS=${homedns}
      PUBLICDNS="1.1.1.1"
      DNS1=10.10.16.10
      DNS2=10.10.17.10

      # Auto-detect which strongSwan mode is active
      # Check if swanctl service is running, otherwise use legacy ipsec
      if systemctl is-active --quiet strongswan-swanctl.service; then
        USE_SWANCTL=true
        echo "Using swanctl mode"
      elif systemctl is-active --quiet strongswan.service; then
        USE_SWANCTL=false
        echo "Using legacy ipsec mode"
      else
        echo "Error: Neither strongswan.service nor strongswan-swanctl.service is active"
        exit 1
      fi

      if [ "$1" == 'up' ]; then
        tailscale_status=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq .BackendState -r)
        if [ "$tailscale_status" == 'Running' ]; then
          ${pkgs.tailscale}/bin/tailscale down
        fi

        if [ "$USE_SWANCTL" = true ]; then
          ${pkgs.strongswan}/bin/swanctl --initiate --child ${connecionName}
        else
          ${pkgs.strongswan}/bin/ipsec up ${connecionName}
        fi

        for INT in "''${INTERFACES[@]}"; do
          if ip link show "$INT" &>/dev/null; then
            echo "Setting DNS for interface $INT"
            sudo resolvectl dns "$INT" "$DNS1" "$DNS2"
          else
            echo "Interface $INT is not available, skipping"
          fi
        done

      elif [ "$1" == 'down' ]; then
        if [ "$USE_SWANCTL" = true ]; then
          ${pkgs.strongswan}/bin/swanctl --terminate --ike ${connecionName}
        else
          ${pkgs.strongswan}/bin/ipsec down ${connecionName}
        fi

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
        if [ "$USE_SWANCTL" = true ]; then
          ${pkgs.strongswan}/bin/swanctl --list-sas
        else
          ${pkgs.strongswan}/bin/ipsec status
        fi

      else
        echo "Usage: ws-vpn {up|down|rdns|status}"
        exit 1
      fi
    '';
in {
  options.extraServices.strongSwan.enable = mkEnableOption "enable strongSwan vpn client";

  config = mkIf cfg.enable {
    sops.secrets."strong-swan.ipsec" = {
      mode = "0600";
      owner = "klowdo";
    };
    # --enable-bypass-lan
    environment.systemPackages = [
      pkgs.strongswan
      shellsScript
    ];
    networking.networkmanager.enableStrongSwan = true;

    # Configure strongswan.conf to disable DNS installation via resolvconf
    # Since NixOS doesn't have a direct option for this, we create the config file
    # This eliminates the "resolvconf is disabled" errors in the logs
    environment.etc."strongswan.conf".text = ''
      charon {
        # We handle DNS manually in the ws-vpn script via resolvectl,
        # so disable strongSwan's DNS installation completely

        # Disable loading of the resolve plugin which handles DNS installation
        plugins {
          resolve {
            load = no
          }
        }
      }
    '';

    services.strongswan = {
      enable = true;
      secrets = [config.sops.secrets."strong-swan.ipsec".path];

      connections = {
        "%default" = {
          ikelifetime = "28800s";
          keylife = "12h";
          rekeymargin = "3m";
          keyingtries = "1";
          keyexchange = "ikev1";
        };
        "${connecionName}" = {
          ike = "aes256-sha256-modp2048!";
          esp = "aes256-sha256-modp2048!";
          xauth = "client";
          xauth_identity = "felix.svensson@nl.worldstream.com";
          leftid = "@10";
          leftauth = "psk";
          leftauth2 = "xauth";
          leftsourceip = "%config";
          right = "vpn-nldw.worldstream.net";
          rightid = "%any";
          rightauth = "psk";
          aggressive = "yes";
          auto = "add";
          rightsubnetwithin = "0.0.0.0/0";
        };
      };
    };
  };
}
