{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.yabai;
in {
  options.features.desktop.yabai = {
    enable = mkEnableOption "Yabai - macOS tiling window manager";
  };

  config = mkIf cfg.enable {
    imports = [
      ./yabai.nix
      ./skhd.nix
    ];
  };
}
