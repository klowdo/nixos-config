{
  # https://nix-community.github.io/nixvim/plugins/toggleterm/index.html
  programs.nixvim = {
    plugins.toggleterm = {
      enable = true;
    };

    keymaps = [
      {
        mode = "";
        # mode = "n";
        key = "<C-/>";
        action = "<cmd>ToggleTerm size=40 dir=git_dor direction=float name=current<CR>";
      }
    ];
  };
}
