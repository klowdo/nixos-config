# Custom NixOS installation ISO configuration
# Build with: nix build .#nixosConfigurations.iso.config.system.build.isoImage
{
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    inputs.disko.nixosModules.disko
  ];

  # ISO image settings
  isoImage = {
    isoName = lib.mkForce "nixos-klowdo-installer.iso";
    volumeID = lib.mkForce "NIXOS_KLOWDO";
    # Include memtest
    includeSystemBuildDependencies = false;
  };

  # Enable SSH for remote installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Set a default password for the nixos user (change this!)
  users.users.nixos.initialPassword = "nixos";
  users.users.root.initialPassword = "nixos";

  # Networking
  networking = {
    hostName = "nixos-installer";
    wireless.enable = false;
    networkmanager.enable = true;
  };

  # Include useful packages for installation
  environment.systemPackages = with pkgs; [
    # Disk tools
    parted
    gptfdisk
    dosfstools
    e2fsprogs
    btrfs-progs
    cryptsetup
    lvm2

    # Network tools
    wget
    curl
    git

    # Editors
    neovim
    nano

    # System tools
    htop
    tmux
    ripgrep
    fd
    tree

    # Hardware info
    pciutils
    usbutils
    lshw
    dmidecode

    # Nix tools
    nix-output-monitor
    nvd

    # YubiKey support
    age-plugin-yubikey
    yubikey-manager
    pcsclite
    ccid

    # SOPS for secrets
    sops
    age
  ];

  # Enable pcscd for YubiKey
  services.pcscd.enable = true;

  # Enable nix flakes
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "nixos"];
    };
    extraOptions = ''
      warn-dirty = false
    '';
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "25.11";
}
