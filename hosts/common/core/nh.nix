{
  programs.nh = {
    enable = true;
    # flake = "/home/user/${config.hostSpec.home}/nix-config";
    flake = "/home/klowdo/.dotfiles/";
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
