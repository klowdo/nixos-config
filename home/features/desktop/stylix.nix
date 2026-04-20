{
  pkgs,
  options,
  lib,
  ...
}:
with lib; {
  config = mkMerge (
    optional (options ? stylix) {
      stylix = {
        enable = mkOverride 1100 true;
        base16Scheme = mkOverride 1100 "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
        image = mkOverride 1100 ../../../lib/Wallpapers/pink-linux.jpg;
        fonts = {
          monospace = {
            package = mkOverride 1100 pkgs.nerd-fonts.jetbrains-mono;
            name = mkOverride 1100 "JetBrainsMono Nerd Font Mono";
          };
          sansSerif = {
            package = mkOverride 1100 pkgs.montserrat;
            name = mkOverride 1100 "Montserrat";
          };
          serif = {
            package = mkOverride 1100 pkgs.montserrat;
            name = mkOverride 1100 "Montserrat";
          };
          sizes = {
            applications = mkOverride 1100 12;
            terminal = mkOverride 1100 15;
            desktop = mkOverride 1100 11;
            popups = mkOverride 1100 12;
          };
        };
        cursor = {
          package = pkgs.banana-cursor;
          name = "Banana";
          size = 16;
        };
        targets = {
          bat.enable = false;
          hyprland.enable = true;
          mako.enable = false;
          gnome.enable = false;
          opencode.enable = false;
        };
      };
    }
  );
}
