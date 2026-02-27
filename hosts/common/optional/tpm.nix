{pkgs, ...}: {
  security.tpm2 = {
    enable = true;
    # PKCS#11 interface for TPM-backed keys
    pkcs11.enable = true;
    # Set TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI to device:/dev/tpmrm0
    tctiEnvironment.enable = true;
  };

  sops.age.plugins = [
    pkgs.age-plugin-tpm
  ];

  environment.systemPackages = with pkgs; [
    tpm2-tools # TPM 2.0 CLI utilities
    age-plugin-tpm # TPM 2.0 support for age/sops
  ];
}
