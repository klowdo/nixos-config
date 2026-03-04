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
      settings = {
        usegeoclue = false;
      };
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

    # Set dark mode as default on activation
    # home.activation.darkmanDefault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   run ${pkgs.darkman}/bin/darkman set dark
    # '';
  };
}
