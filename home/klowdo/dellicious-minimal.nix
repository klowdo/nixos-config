{...}: {
  imports = [
    ./home-minimal.nix
    ./dotfiles/git.nix
    ../features/cli/zsh.nix
    ../features/cli/fzf.nix
    ../features/cli/ssh.nix
    ../features/cli/nh.nix
    ../common
    ../common/optional/sops.nix
  ];

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      ssh.enable = true;
      nh.enable = true;
    };
  };
}
