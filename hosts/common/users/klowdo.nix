{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  hardware.keyboard.zsa.enable = true;

  sops.secrets."passwords/klowdo".neededForUsers = true;
  users.mutableUsers = false;

  users.users.klowdo = {
    hashedPasswordFile = config.sops.secrets."passwords/klowdo".path;
    # password = lib.mkForce "nixos"; # Uncomment to set temporary password until sops passwords work
    isNormalUser = true;
    description = "Felix Svensson";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./klowdo/keys/id_ed25519.pub)
    ];
    shell = pkgs.zsh;
    packages = [pkgs.home-manager];
  };
  home-manager.users.klowdo =
    import ../../../home/klowdo/${config.networking.hostName}.nix;
}
