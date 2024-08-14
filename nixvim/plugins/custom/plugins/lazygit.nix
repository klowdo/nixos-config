{
  # opens lazygit :)
  # https://nix-community.github.io/nixvim/plugins/lazygit/index.html
  programs.nixvim = {
    plugins.lazygit = {
      enable = true;
    };

    keymaps = [
      {
        mode = "";
        # mode = "n";
        key = "<leader>lg";
        action = "<cmd>LazyGit<CR>";
      }
    ];
  };
}
