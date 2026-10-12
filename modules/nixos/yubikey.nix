{
  flake.modules.nixos.yubikey = {pkgs, ...}: {
    services.pcscd.enable = true;

    services.udev.packages = [pkgs.yubikey-personalization];

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
      yubikey-manager
      yubico-piv-tool
      age-plugin-yubikey
    ];
  };
}
