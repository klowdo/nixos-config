{
  # https://nix-community.github.io/nixvim/plugins/snacks/index.html
  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      settings = {
        bigfile = {enabled = true;};
        dashboard = {enabled = true;};
        indent = {enabled = true;};
        input = {enabled = true;};
        notifier = {enabled = true;};
        quickfile = {enabled = true;};
        scroll = {enabled = true;};
        statuscolumn = {enabled = true;};
        words = {enabled = true;};
        terminal = {
        };
      };
    };
  };
}
