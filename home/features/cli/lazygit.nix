{pkgs, ...}: {
  programs.lazygit = {
    enable = true;
    package = pkgs.unstable.lazygit;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never --line-numbers";
        };
        pagers = [
          {pager = "delta --dark --paging=never --line-numbers";}
          {pager = "difft --color=always";}
        ];
      };
      customCommands = [
        {
          key = "o";
          command = "sesh connect '{{.SelectedWorktree.Path}}'";
          context = "worktrees";
          description = "Open worktree in sesh session";
        }
        {
          key = "s";
          command = "sesh connect '{{.SelectedWorktree.Path}}'";
          context = "worktrees";
          description = "Connect to worktree session";
        }
      ];
    };
  };

  # Install delta and difftastic for use with lazygit
  home.packages = with pkgs; [
    delta
    difftastic
  ];
}
