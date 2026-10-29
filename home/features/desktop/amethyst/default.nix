{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.amethyst;
in
{
  options.features.desktop.amethyst = {
    enable = mkEnableOption "Amethyst tiling window manager for macOS";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Import Amethyst configuration
      imports = [ ./amethyst.nix ];
    }
  ]);
}
