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
  imports = [ ./amethyst.nix ];

  options.features.desktop.amethyst = {
    enable = mkEnableOption "Amethyst tiling window manager for macOS";
  };
}
