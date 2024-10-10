{
  # https://nix-community.github.io/nixvim/plugins/toggleterm/index.html
  programs.nixvim = {
    plugins.oil = {
      enable = true;
    };

    keymaps = [
      {
        key = "<leader>e";
        mode = "n";
        action = "<CMD>Oil<CR>";
        options = {
          desc = "[E]xpore ";
        };
      }
    ];
  };
}
