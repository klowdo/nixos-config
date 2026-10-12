{
  flake.modules.nixos.tpm = {pkgs, ...}: {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    sops.age.plugins = [
      pkgs.age-plugin-tpm
    ];

    environment.systemPackages = with pkgs; [
      tpm2-tools
      age-plugin-tpm
    ];
  };
}
