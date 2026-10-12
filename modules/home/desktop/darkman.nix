{...}: {
  flake.modules.homeManager.darkman = {pkgs, ...}: {
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
  };
}
