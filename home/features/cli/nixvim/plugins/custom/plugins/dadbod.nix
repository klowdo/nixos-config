{
  # https://nix-community.github.io/nixvim/plugins/toggleterm/index.html
  programs.nixvim = {
    plugins.vim-dadbod = {
      enable = true;
    };

    plugins.vim-dadbod-completion = {
      enable = true;
    };
    plugins.vim-dadbod-ui = {
      enable = true;
    };
  };
}
