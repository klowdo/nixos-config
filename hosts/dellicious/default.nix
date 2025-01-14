# A staring point is the basic NIXOS configuration generated by the ISO installer.
# On an existing NIXOS install you can use the following command in your flakes basedir:
# sudo nixos-generate-config --dir ./hosts/m3tam3re
#
# Please make sure to change the first couple of lines in your configuration.nix:
# { config, inputs, ouputs, lib, pkgs, ... }:
#
# {
#   imports = [ # Include the results of the hardware scan.
#     ./hardware-configuration.nix
#     inputs.home-manager.nixosModules.home-manager
#   ];
#   ...
#
# Moreover please update the packages option in your user configuration and add the home-manager options:
# users.users = {
#   m3tam3re = {
#     isNormalUser = true;
#     initialPassword = "12345";
#     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
#     packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
#   };
# };
#
# home-manager = {
#   useUserPackages = true;
#   extraSpecialArgs = { inherit inputs outputs; };
#   users.m3tam3re =
#     import ../../home/m3tam3re/${config.networking.hostName}.nix;
# };
#
# Please also change your hostname accordingly:
#:w
# networking.hostName = "nixos"; # Define your hostname.
{outputs, ...}: {
  imports = [
    ../common
    ./configuration.nix
    # ./services
    ./secrets.nix
  ];

  extraServices = {
    podman.enable = true;
    # hyprlock.enable = true;
    swaylock.enable = true;
    auto-cpufreq.enable = true;
    tlp.enable = true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
