{config, ...}: let
  homeDirectory = config.home.homeDirectory;
  sopsAgeDir = "${homeDirectory}/.config/sops/age";

  # Regular age key file (generated via: just sops-init)
  # For YubiKey setup, use: just yubikey-save-identity to generate yubikey-identity.txt
  regularKeyFile = "${sopsAgeDir}/keys.txt";
in {
  # sops-nix module is loaded via sharedModules in hosts/common/default.nix
  sops = {
    # Age key configuration for decryption
    # Priority: YubiKey identity if exists, otherwise regular age key
    #
    # For YubiKey setup:
    #   1. Run: just yubikey-setup (interactive setup on YubiKey)
    #   2. Run: just yubikey-save-identity (saves identity to ~/.config/sops/age/yubikey-identity.txt)
    #   3. Add the public key to .sops.yaml
    #   4. Run: just sops-updatekeys
    #
    # Note: When using YubiKey, it must be present for secret decryption
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

      "application/homeassistant/token" = {};
    };
  };
}
