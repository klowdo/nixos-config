{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./home.nix
    ./dotfiles/git.nix
    ../features/cli
    ../common
    ../common/optional/sops.nix
  ];

  userConfig.username = lib.mkForce "FSVENS28";

  home.packages = [pkgs.neovim];

  features.cli = {
    zsh.enable = true;
    fzf.enable = true;
    fastfetch.enable = true;
    yazi.enable = true;
    tmux.enable = true;
    sesh.enable = true;
    gh.enable = true;
    ssh.enable = true;
    tools.enable = true;
    archives.enable = true;
  };
}
