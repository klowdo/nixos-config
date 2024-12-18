{
  config,
  pkgs,
  inputs,
  ...
}: {
  hardware.keyboard.zsa.enable = true;
  users.users.klowdo = {
    initialHashedPassword = "$y$j9T$/nxF1ltBc38vOPhGNfjHE.$tf6BVIXMkWkgUFXciZu/g1QVH/Zd5eSH5oIjMK5Xd95";
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkGJ4oiQKSQc/stxvyBo1sgsNgKiH6/9EYQz7p9n8iX klowdo.fs@gmail.com"
    ];
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.klowdo =
    import ../../../home/klowdo/${config.networking.hostName}.nix;
}
