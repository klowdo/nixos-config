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
    package = pkgs.gitAndTools.gitFull;
    userName = "Felix Svensson";
    userEmail = "klowdo.fs@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
    difftastic = {
      enable = true;
    };
    extraConfig = {
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
      extraConfig = {
        credential.helper = "store";
      };
    };
  };
}
