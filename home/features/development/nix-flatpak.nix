{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.nix-flatpak;
in {
  options.features.development.nix-flatpak.enable = mkEnableOption "enable nix-flatpak for declarative Flatpak management in Home Manager";

  # Import nix-flatpak Home Manager module from flake input
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];
  config = mkIf cfg.enable {
    # Enable Flatpak for user
    services.flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Default value
      };
    };
  };
}
