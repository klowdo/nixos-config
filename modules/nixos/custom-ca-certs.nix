{
  flake.modules.nixos.custom-ca-certs = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets."ssh/customer-1/ca-certs" = {
      mode = "0644";
    };

    systemd.services.update-ca-trust = {
      description = "Update CA trust store with custom certificates";
      after = ["sops-nix.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /etc/ssl/certs
        if [ -f "${config.sops.secrets."ssh/customer-1/ca-certs".path}" ]; then
          ${pkgs.coreutils}/bin/cp "${config.sops.secrets."ssh/customer-1/ca-certs".path}" /etc/ssl/certs/worldstream-ca.pem
          ${pkgs.cacert}/bin/update-ca-certificates || true
        fi
      '';
    };
  };
}
