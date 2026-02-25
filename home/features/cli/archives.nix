{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.archives;
in {
  options.features.cli.archives.enable = mkEnableOption "enable archive extraction tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unzip
      unrar
      p7zip
    ];
  };
}
