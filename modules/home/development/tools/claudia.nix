{...}: {
  flake.modules.homeManager.claudia = {
    programs.claudia = {
      enable = false;
    };
  };
}
