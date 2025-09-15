{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
  ];
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    image = ../../lib/nix-wallpaper-nineish-catppuccin-macchiato.png;

    cursor = {
      package = pkgs.banana-cursor;
      name = "Banana";
      size = 16;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
    targets = {
      bat.enable = false;
      hyprland.enable = true;
      mako.enable = false;
    };
  };
}
