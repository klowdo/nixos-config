{
  # https://nix-community.github.io/nixvim/plugins/tmux-navigator/index.html
  programs.nixvim = {
    plugins.tmux-navigator = {
      enable = true;
    };
  };
}
