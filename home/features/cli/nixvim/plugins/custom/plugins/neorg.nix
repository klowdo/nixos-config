{
  # https://nix-community.github.io/nixvim/plugins/toggleterm/index.html
  programs.nixvim = {
    plugins.neorg = {
      enable = true;
      extraOptions = {
        telescopeIntegration.enable = true;
        load = {
          "core.concealer" = {
            config = {
              icon_preset = "varied";
            };
          };
          "core.defaults" = {
            __empty = null;
          };
          "core.journal" = {
            __empty = null;
          };

          "core.completion" = {
            config = {
              engine = "nvim-cmp";
            };
          };
          "core.dirman" = {
            config = {
              workspaces = {
                home = "~/notes/home";
                work = "~/notes/work";
                school = "~/notes/school";
              };
              default_workspace = "school";
            };
          };
        };
      };
    };

    # keymaps = [
    #   {
    #     mode = "";
    #     # mode = "n";
    #     key = "<C-/>";
    #     action = "<cmd>ToggleTerm size=40 dir=git_dor direction=float name=current<CR>";
    #   }
    # ];
  };
}
