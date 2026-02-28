{
  config,
  options,
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
  config = mkIf cfg.enable (mkMerge (
    (optional (options ? stylix) {
      stylix.targets.spicetify.enable = false;
    })
    ++ [
      {
        programs.spicetify = let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in {
          enable = true;
          wayland = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblock
            hidePodcasts
            history
            keyboardShortcut
            shuffle
          ];
          theme = lib.mkDefault spicePkgs.themes.catppuccin;
          colorScheme = lib.mkDefault "mocha";
        };
      }
    ]
  ));
}
