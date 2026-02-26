{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];
  sops = {
    # Default secrets file for the system
    defaultSopsFile = ../../../secrets.yaml;
    # Disabled: secrets.yaml contains secrets for multiple hosts/users
    # Validation would fail when a host doesn't use all defined secrets
    validateSopsFiles = false;

    age = {
      # Primary key file for host decryption (generated from SSH host key)
      keyFile = "/var/lib/sops-nix/age/key.txt";

      # SSH host keys to derive age keys from
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];

      # Generate age key from SSH host key if it doesn't exist
      generateKey = true;

      # Hardware security plugins for age encryption/decryption
      plugins = [
        pkgs.age-plugin-yubikey
        pkgs.age-plugin-tpm
      ];

      # ============================================================
      # Hardware Security Options (YubiKey / TPM)
      # ============================================================
      #
      # The recommended approach is to use hardware keys (YubiKey/TPM) for ENCRYPTION only,
      # while using the host's SSH-derived age key for DECRYPTION during system activation.
      # This avoids requiring hardware presence during boot.
      #
      # --- YubiKey Support ---
      # If using a YubiKey for system-level decryption:
      # 1. Generate identity: just yubikey-setup
      # 2. Save identity: just yubikey-save-identity
      # 3. Copy identity file to: /etc/sops/age/yubikey-identity.txt
      # 4. Uncomment: keyFile = "/etc/sops/age/yubikey-identity.txt";
      # Note: Requires YubiKey to be present during boot/activation
      #
      # --- TPM 2.0 Support ---
      # If using TPM for system-level decryption:
      # 1. Check TPM: just tpm-check
      # 2. Generate identity: just tpm-save-identity
      # 3. Copy identity file to: /etc/sops/age/tpm-identity.txt
      # 4. Uncomment: keyFile = "/etc/sops/age/tpm-identity.txt";
      # Note: TPM is always present, making it ideal for unattended decryption
      #
      # For encryption, add the public keys (age1yubikey1... or age1tpm1...) to .sops.yaml
      # Then run: just sops-updatekeys
    };

    # Secrets are available at runtime in $XDG_RUNTIME_DIR (Linux) or DARWIN_USER_TEMP_DIR (Darwin)
    # Example: /run/user/1000/secrets/my-secret
    # secrets = {
    #   "tokens/foo" = {};
    # };
  };
}
