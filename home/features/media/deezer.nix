{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.media.deezer;
in {
  options.features.media.deezer.enable = mkEnableOption "enable deezer music streaming";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      deezer-linux
    ];
  };
}
