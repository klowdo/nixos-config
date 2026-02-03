{pkgs, ...}: {
  # Smart card daemon for YubiKey communication
  services.pcscd.enable = true;

  # udev rules for YubiKey access
  services.udev.packages = [pkgs.yubikey-personalization];

  # GnuPG agent with SSH support (for GPG keys on YubiKey)
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # TPM 2.0 support
  # Note: Most modern systems have TPM built-in, enable tcsd if using older TPM 1.2
  security.tpm2 = {
    enable = true;
    # Allow user-space applications to access TPM
    abrmd.enable = true;
    # Add current user to tss group for TPM access (handled by users config)
    pkcs11.enable = true;
  };

  # System packages for hardware security (YubiKey + TPM) with age plugins for sops-nix
  environment.systemPackages = with pkgs; [
    # YubiKey management tools
    yubikey-personalization
    yubioath-flutter
    yubikey-manager # ykman CLI
    yubico-piv-tool

    # TPM 2.0 tools
    tpm2-tools # TPM 2.0 CLI utilities
    tpm2-abrmd # TPM Access Broker & Resource Manager Daemon

    # age encryption with hardware security plugins
    age-plugin-yubikey # YubiKey support for age/sops
    age-plugin-tpm # TPM 2.0 support for age/sops
  ];
}
