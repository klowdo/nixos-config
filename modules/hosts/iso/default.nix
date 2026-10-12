# Build with: nix build .#nixosConfigurations.iso.config.system.build.isoImage
# Build with: nix build .#nixosConfigurations.iso-minimal.config.system.build.isoImage
{inputs, ...}: let
  common = import ./_common.nix inputs;
  mkIso = installer:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({modulesPath, ...}: {
          imports = [
            "${modulesPath}/installer/cd-dvd/${installer}.nix"
            "${modulesPath}/installer/cd-dvd/channel.nix"
          ];
        })
        common
      ];
    };
in {
  flake.nixosConfigurations = {
    iso = mkIso "installation-cd-graphical-gnome";
    iso-minimal = mkIso "installation-cd-minimal";
  };
}
