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
        # Multiple pagers - cycle through them with pipe (|) key
        pagers = [
          {pager = "delta --dark --paging=never --line-numbers";}
          {pager = "difft --color=always";}
        ];
      };
    };
  };

  # Install delta and difftastic for use with lazygit
  home.packages = with pkgs; [
    delta
    difftastic
  ];
}
