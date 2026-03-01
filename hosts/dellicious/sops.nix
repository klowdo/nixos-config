{config, ...}: {
  sops.secrets."hosts/dellicious/ssh_host_ed25519_key" = {
    mode = "0600";
  };

  environment.etc."ssh/ssh_host_ed25519_key.pub" = {
    source = ./ssh_host_ed25519_key.pub;
    mode = "0644";
  };

  system.activationScripts.installSshHostKey = {
    deps = ["setupSecrets"];
    text = ''
      if [[ ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
        secret="${config.sops.secrets."hosts/dellicious/ssh_host_ed25519_key".path}"
        if [[ -f "$secret" ]]; then
          echo "Installing SSH host key from sops secret..."
          cp "$secret" /etc/ssh/ssh_host_ed25519_key
          chmod 600 /etc/ssh/ssh_host_ed25519_key
          chown root:root /etc/ssh/ssh_host_ed25519_key
        fi
      fi
    '';
  };
}
