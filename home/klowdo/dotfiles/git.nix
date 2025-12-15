{
  pkgs,
  config,
  ...
}: {
  sops.secrets.".git-credentials" = {
    sopsFile = ../../../secrets.yaml;
    mode = "0600";
    path = ".git-credentials";
  };
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user = {
        name = "Felix Svensson";
        email = "klowdo.fs@gmail.com";
      };
      alias = {
        ci = "commit";
        co = "checkout";
        st = "status";
      };
      init.defaultBranch = "main";

      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
      diff.algorithm = "histogram";
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";
      # Automatically track remote branch
      push.autoSetupRemote = true;
      # Reuse merge conflict fixes when rebasing
      rerere.enabled = true;
      rebase.updateRefs = true;
      pull.rebase = true;
      credential.helper = "store";
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
