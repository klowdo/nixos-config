{...}: {
  flake.modules.homeManager.fonts = {pkgs, ...}: {
    home.packages = with pkgs; [
      fira-code
      fira-code-symbols
      fira-code
      font-manager
      font-awesome_5
      noto-fonts
    ];
    fonts.fontconfig.enable = true;
  };
}
