{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.media.spicetify;
in {
  options.features.media.spicetify.enable = mkEnableOption "enable spotify";

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];
  config = mkIf cfg.enable {
    programs.spicetify = let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        history
        keyboardShortcut
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      theme = lib.mkDefault spicePkgs.themes.catppuccin;
      colorScheme = lib.mkDefault "mocha";
    };
  };
}
