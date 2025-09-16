{inputs, ...}: let
  homeDirectory = "/home/klowdo";
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];
  sops = {
    # This is the location of the host specific age-key for ta and will to have been extracted to this location via hosts/common/core/sops.nix on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

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
    };
  };
}
