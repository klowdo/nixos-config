{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.libreoffice;
in {
  options.features.development.tools.libreoffice.enable = mkEnableOption "enable libre office QT";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.sv_SE
      hunspellDicts.en_US
    ];
  };
}
