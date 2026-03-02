{
  config,
  pkgs,
  ...
}: {
  # Deploy CA certificate from SOPS
  sops.secrets."ssh/customer-1/ca-certs" = {
    mode = "0644";
  };

  # Create a systemd service to update CA trust after SOPS activates
  systemd.services.update-ca-trust = {
    description = "Update CA trust store with custom certificates";
    after = ["sops-nix.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Copy the CA cert to the system trust store
      mkdir -p /etc/ssl/certs
      if [ -f "${config.sops.secrets."ssh/customer-1/ca-certs".path}" ]; then
        ${pkgs.coreutils}/bin/cp "${config.sops.secrets."ssh/customer-1/ca-certs".path}" /etc/ssl/certs/worldstream-ca.pem
         # Update the CA certificate database
        ${pkgs.cacert}/bin/update-ca-certificates || true
      fi
    '';
  };
}
