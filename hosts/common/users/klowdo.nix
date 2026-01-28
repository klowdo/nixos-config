{
  config,
  pkgs,
  ...
}: let
  # Filter groups to only those that exist on this system
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  hardware.keyboard.zsa.enable = true;

  # Enable GNOME Keyring with SSH agent support (configured in optional/gnome-keyring.nix)
  services.gnome.gnome-keyring-ssh.enable = true;

  sops.secrets."passwords/klowdo".neededForUsers = true;
  users.mutableUsers = false;

  users.users.klowdo = {
    hashedPasswordFile = config.sops.secrets."passwords/klowdo".path;
    # password = lib.mkForce "nixos"; # Uncomment to set temporary password until sops passwords work
    isNormalUser = true;
    description = "Felix Svensson";
    extraGroups =
      ["wheel" "networkmanager" "audio" "video" "input"]
      ++ ifTheyExist [
        "libvirtd"
        "flatpak"
        "plugdev"
        "kvm"
        "qemu-libvirtd"
        "docker"
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
