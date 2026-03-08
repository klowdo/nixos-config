{
  # nh flake path is set via hostConfig.dotfilesPath in host-config module
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
