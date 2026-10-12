# Age key: software key at ~/.config/sops/age/keys.txt (just sops-init).
# Hardware alternatives (just yubikey-save-identity / just tpm-save-identity)
# write yubikey-identity-1.txt / tpm-identity.txt into the same directory;
# point age.keyFile at one of them after adding its public key to .sops.yaml
# and running just sops-updatekeys.
{inputs, ...}: {
  flake.modules.homeManager.sops = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.home) homeDirectory;
    sopsAgeDir = "${homeDirectory}/.config/sops/age";
    regularKeyFile = "${sopsAgeDir}/keys.txt";
  in {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops = {
      age.keyFile = regularKeyFile;
      age.plugins = [
        pkgs.age-plugin-yubikey
        pkgs.age-plugin-tpm
      ];

      defaultSopsFile = ../../secrets.yaml;
      # secrets.yaml holds secrets for multiple hosts/users; validation would
      # fail when a host doesn't use all of them.
      validateSopsFiles = false;

      secrets = {
        "private_keys/klowdo" = {
          path = "${homeDirectory}/.ssh/id_ed25519";
        };
        "private_keys/klowdo_rsa" = {
          path = "${homeDirectory}/.ssh/id_rsa";
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

        "applications/homeassistant/token" = {};

        "applications/linkding/token" = {};

        "applications/gitlab/token" = {};

        "applications/jetbrains-junie/token" = {};

        "applications/cachix/token" = {};
      };
    };
  };
}
