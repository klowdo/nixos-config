{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.strongSwan;
  connecionName = "worlstream";
  homedns = "192.168.10.1";
  shellsScript =
    pkgs.writeShellScriptBin "ws-vpn"
    # shell
    ''
      INTERFACES=("enp0s20f0u1u1" "wlp0s20f3")
      # HOMEDNS=192.168.1.252
      HOMEDNS=${homedns}
      DNS1=10.10.16.10
      DNS2=10.10.17.10

      if [ "$1" == 'up' ]; then
        tailscale_status=$(${pkgs.tailscale}/bin/tailscale status  --json | ${pkgs.jq}/bin/jq .BackendState -r)
        if [ "$tailscale_status" == 'Running' ]; then
          ${pkgs.tailscale}/bin/tailscale  down
        fi
        ${pkgs.strongswan}/bin/ipsec up ${connecionName}


        for INT in "''${INTERFACES[@]}"; do
          # Check if interface exists
          if ip link show "$INT" &>/dev/null; then
            echo "Setting DNS for interface $INT"
            sudo resolvectl dns "$INT" "$DNS1" "$DNS2"
          else
            echo "Interface $INT is not available, skipping"
          fi
        done


      elif [ "$1" == 'down' ]; then
        ${pkgs.strongswan}/bin/ipsec down ${connecionName}

        for INT in "''${INTERFACES[@]}"; do
          # Check if interface exists
          if ip link show "$INT" &>/dev/null; then
            echo "Setting HOME DNS for interface $INT"
            sudo resolvectl dns "$INT" "$HOMEDNS"
          else
            echo "Interface $INT is not available, skipping"
          fi
        done


        ${pkgs.tailscale}/bin/tailscale up
      else
        echo "have no idea what to do"
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
