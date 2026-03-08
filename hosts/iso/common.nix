# Shared configuration for all NixOS installation ISOs
{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  # ISO image settings (using new option names)
  image.fileName = lib.mkForce "nixos-klowdo-installer.iso";
  isoImage = {
    volumeID = lib.mkForce "NIXOS_KLOWDO";
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
  users.users = {
    # Override the default empty password with "nixos" for both users
    # The installer sets initialHashedPassword = "", we override with initialPassword
    nixos.initialHashedPassword = lib.mkForce null;
    root.initialHashedPassword = lib.mkForce null;
    nixos.initialPassword = "nixos";
    root.initialPassword = "nixos";
  };

  # Networking
  networking = {
    hostName = "nixos-installer";
    wireless.enable = false;
    networkmanager.enable = true;
  };

  # Include useful packages for installation
  environment.systemPackages = with pkgs; [
    # Custom install scripts
    (writeShellScriptBin "install-helper" (builtins.readFile ../../scripts/install-helper.sh))

    # Disk tools
    parted
    gptfdisk
    dosfstools
    e2fsprogs
    btrfs-progs
    cryptsetup
    lvm2
    bc

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
