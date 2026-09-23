{
  pkgs,
  config,
  lib,
  ...
}: let
  gpgEnabled = config.features.cli.gpg.enable;
  gpgCfg = config.features.cli.gpg;
in {
  sops.secrets.".git-credentials" = {
    sopsFile = ../../../secrets.yaml;
    mode = "0600";
    path = ".git-credentials";
  };
  home.packages = with pkgs; [
    git-absorb
    git-extras
  ];
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user =
        {
          name = config.userConfig.fullName;
          inherit (config.userConfig) email;
        }
        // lib.optionalAttrs (gpgEnabled && gpgCfg.keyId != "") {
          signingkey = gpgCfg.keyId;
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
      push.autoSetupRemote = true;
      rerere.enabled = true;
      rebase.updateRefs = true;
      pull.rebase = true;
      credential.helper = "store";

      # GPG commit signing (enabled via features.cli.gpg)
      commit.gpgsign = gpgEnabled && gpgCfg.enableGitSigning;
      tag.gpgsign = gpgEnabled && gpgCfg.enableGitSigning;
    };
    includes = [
      {
        condition = "gitdir:~/dev/work/";
        contents = {
          user.email = "felix@flixen.se";
        };
      }
    ];
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
