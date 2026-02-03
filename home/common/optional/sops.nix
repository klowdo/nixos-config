{config, ...}: let
  homeDirectory = config.home.homeDirectory;
  sopsAgeDir = "${homeDirectory}/.config/sops/age";

  # Regular age key file (generated via: just sops-init)
  regularKeyFile = "${sopsAgeDir}/keys.txt";

  # Hardware security identity files (generated via just commands)
  # yubikeyIdentityFile = "${sopsAgeDir}/yubikey-identity-1.txt";
  # tpmIdentityFile = "${sopsAgeDir}/tpm-identity.txt";
in {
  # sops-nix module is loaded via sharedModules in hosts/common/default.nix
  sops = {
    # Age key configuration for decryption
    # Default: software-based age key at ~/.config/sops/age/keys.txt
    #
    # ============================================================
    # Hardware Security Options (YubiKey / TPM)
    # ============================================================
    #
    # --- YubiKey Setup ---
    #   1. Run: just yubikey-setup (interactive setup on YubiKey)
    #   2. Run: just yubikey-save-identity (saves to ~/.config/sops/age/yubikey-identity-1.txt)
    #   3. Add the public key (age1yubikey1...) to .sops.yaml
    #   4. Run: just sops-updatekeys
    #   5. Change keyFile below to: yubikeyIdentityFile
    # Note: YubiKey must be present for secret decryption
    #
    # --- TPM 2.0 Setup ---
    #   1. Run: just tpm-check (verify TPM is available)
    #   2. Run: just tpm-save-identity (saves to ~/.config/sops/age/tpm-identity.txt)
    #   3. Add the public key (age1tpm1...) to .sops.yaml
    #   4. Run: just sops-updatekeys
    #   5. Change keyFile below to: tpmIdentityFile
    # Note: TPM is always present, ideal for automatic decryption
    #
    age.keyFile = regularKeyFile;

    defaultSopsFile = ../../../secrets.yaml;
    # Disabled: secrets.yaml contains secrets for multiple hosts/users
    # Validation would fail when a host doesn't use all defined secrets
    validateSopsFiles = false;

    secrets = {
      "private_keys/klowdo" = {
        path = "${homeDirectory}/.ssh/id_ed25519";
      };
      "email/gmail-password" = {
        path = "${homeDirectory}/.config/neomutt/gmail-password";
      };
      "email/office365-password" = {
        path = "${homeDirectory}/.config/neomutt/office365-password";
      };
      "passwords/klowdo" = {
        path = "${homeDirectory}/.config/pass/gpg-passphrase";
        mode = "0400";
      };

      "weather-api-key" = {};

      "claude/oauth-token" = {};
    };
  };
}
