{inputs, ...}: {
  flake.modules.nixos.sops = {pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops = {
      defaultSopsFile = ../../secrets.yaml;
      # secrets.yaml contains secrets for multiple hosts/users; validation
      # would fail when a host doesn't use all defined secrets
      validateSopsFiles = false;

      age = {
        keyFile = "/var/lib/sops-nix/age/key.txt";
        sshKeyPaths = [
          "/etc/ssh/ssh_host_ed25519_key"
        ];
        generateKey = true;
        plugins = [
          pkgs.age-plugin-yubikey
          pkgs.age-plugin-tpm
        ];
      };
    };
  };
}
