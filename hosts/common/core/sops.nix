{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];
  sops = {
    # Default secrets file for the system
    defaultSopsFile = ../../../secrets.yaml;
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

      # YubiKey Support:
      # If using a YubiKey for system-level decryption, add the YubiKey identity file:
      # Note: This requires the YubiKey to be present during boot/activation
      # keyFile = "/etc/sops/age/yubikey-identity.txt";
      #
      # Alternatively, add YubiKey public key to .sops.yaml and use regular host key for decryption
      # This is the recommended approach - YubiKey for encryption only, host key for decryption
    };

    # Secrets are available at runtime in $XDG_RUNTIME_DIR (Linux) or DARWIN_USER_TEMP_DIR (Darwin)
    # Example: /run/user/1000/secrets/my-secret
    # secrets = {
    #   "tokens/foo" = {};
    # };
  };
}
