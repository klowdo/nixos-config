{
  inputs,
  lib,
  ...
}: let
  homeDirectory = "/home/klowdo";
  sopsAgeDir = "${homeDirectory}/.config/sops/age";

  # YubiKey identity file (generated via: just yubikey-save-identity)
  yubikeyIdentityFile = "${sopsAgeDir}/yubikey-identity.txt";

  # Regular age key file (generated via: just sops-init)
  regularKeyFile = "${sopsAgeDir}/keys.txt";
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];
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
