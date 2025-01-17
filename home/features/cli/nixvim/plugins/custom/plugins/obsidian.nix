{
  # https://nix-community.github.io/nixvim/plugins/obsidian/settings/index.html
  programs.nixvim = {
    plugins.obsidian = {
      enable = true;
      settings = {
        completion = {
          min_chars = 2;
          nvim_cmp = true;
        };
        new_notes_location = "current_dir";
        workspaces = [
          {
            name = "work";
            path = "~/obsidian/work";
          }
          {
            name = "school";
            path = "~/obsidian/school";
          }
          {
            name = "home";
            path = "~/obsidian/home";
          }
        ];
      };
    };
  };
}
