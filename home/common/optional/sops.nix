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
    };
  };
}
