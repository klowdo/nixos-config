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
        };
      };
    }
  );
}
