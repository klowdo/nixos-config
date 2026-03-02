# Common configuration for all hosts
# Creds https://code.m3tam3re.com/m3tam3re/nixcfg
{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      ./core
      ./optional
      ./optional/services
      ./users
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
    ]
    ++ (builtins.attrValues outputs.nixosModules);
  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "bak";
    sharedModules = [
    ];
  };

  nixpkgs = {
    # You can add overlays here
    overlays = builtins.attrValues outputs.overlays;
    # Configure your nixpkgs instance
    # Note: allowUnfree is set in ./core/default.nix
    config = {
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "klowdo"
      ]; # Set users that are allowed to use the flake command
    };
    # not needed with nh
    # gc = {
    #   automatic = true;
    #   options = "--delete-older-than 30d";
    # };
    optimise.automatic = true;
    registry =
      (lib.mapAttrs (_: flake: {inherit flake;}))
      ((lib.filterAttrs (_: lib.isType "flake")) inputs);
    nixPath = ["/etc/nix/path"];
  };

  users.defaultUserShell = pkgs.zsh;

  # Host-wide configuration (used by various modules)
  # home and dotfilesPath have smart defaults based on mainUser
  hostConfig.mainUser = "klowdo";

  system.stateVersion = "25.11";
}
