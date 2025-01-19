{
  # https://nix-community.github.io/nixvim/plugins/markview/index.html
  programs.nixvim = {
    plugins.markview = {
      enable = true;
    };
  };
}
