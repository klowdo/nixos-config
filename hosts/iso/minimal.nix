# Minimal NixOS installation ISO configuration (CLI only)
# Build with: nix build .#nixosConfigurations.iso-minimal.config.system.build.isoImage
{modulesPath, ...}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    ./common.nix
  ];
}
