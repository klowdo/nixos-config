# Graphical NixOS installation ISO configuration (default)
# Build with: nix build .#nixosConfigurations.iso.config.system.build.isoImage
{modulesPath, ...}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    ./common.nix
  ];
}
