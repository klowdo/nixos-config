{...}: {
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      settings = {
        font_size = 12;
      };
      shellIntegration = {
        enableZshIntegration = true;
      };
    };
  };
}
