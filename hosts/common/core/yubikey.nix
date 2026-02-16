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

  sops.age.plugins = [
    pkgs.age-plugin-yubikey
  ];

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubioath-flutter
    yubico-pam

    yubikey-agent
    yubikey-manager
    yubioath-flutter
    yubikey-manager # ykman CLI
    yubico-piv-tool
    age-plugin-yubikey # YubiKey support for age/sops
  ];
}
