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

  # System packages for YubiKey + age-plugin-yubikey (for sops-nix)
  environment.systemPackages = with pkgs; [
    # YubiKey management tools
    yubikey-personalization
    yubikey-personalization-gui
    yubikey-manager # ykman CLI
    yubico-piv-tool

    # age encryption with YubiKey support
    age-plugin-yubikey
  ];
}
