{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];
  sops = {
    # This is the location of the host specific age-key for ta and will to have been extracted to this location via hosts/common/core/sops.nix on the host

    defaultSopsFile = ../../../secrets.yaml;
    validateSopsFiles = false;
    age = {
      keyFile = "/var/lib/sops-nix/age/key.txt";
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      generateKey = true;
    };

    # Linux: Exists in $XDG_RUNTIME_DIR/id_foo
    # Darwin: Exists in $(getconf DARWIN_USER_TEMP_DIR)
    #   ex: /var/folders/pp/t8_sr4ln0qv5879cp3trt1b00000gn/T/id_foo
    # secrets = {
    #   #placeholder for tokens that I haven't gotten to yet
    #   #"tokens/foo" = {
    #   #};
    # };
  };
}
