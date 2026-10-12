{...}: {
  flake.modules.homeManager.nh = {config, ...}: {
    programs.nh = {
      enable = true;
      flake = config.userConfig.dotfilesPath;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };
}
