{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.darkman;
in {
  options.features.desktop.darkman = {
    enable = mkEnableOption "darkman manager";
  };

  config = mkIf cfg.enable {
    services.darkman = {
      enable = true;
      darkModeScripts = {
        gtk-theme = ''
          ${pkgs.dconf}/bin/dconf write \
              /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        '';
      };
      lightModeScripts = {
        gtk-theme = ''
          ${pkgs.dconf}/bin/dconf write \
              /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        '';
      };
    };
  };
}
