{pkgs, ...}: {
  # fonts.fontconfig.enable = true;
  # home.packages = [
  #   pkgs.noto-fonts
  #   pkgs.nerdfonts # loads the complete collection. look into overide for FiraMono or potentially mononoki
  #   pkgs.meslo-lgs-nf
  # ];
  #;  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.noto-fonts
    pkgs.nerdfonts # loads the complete collection. look into overide for FiraMono or potentially mononoki
    pkgs.meslo-lgs-nf
  ];

  # TODO add ttf-font-awesome or font-awesome for waybar
  # fontProfiles = {
  #   enable = true;
  #   monospace = {
  #     family = "FiraCode Nerd Font";
  #     package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
  #   };
  #   regular = {
  #     family = "Fira Sans";
  #     package = pkgs.fira;
  #   };
  # };
}
