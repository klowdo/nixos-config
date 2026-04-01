{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./fzf.nix
    ./fastfetch.nix
    ./yazi.nix
    ./password-store.nix
    ./nh.nix
    ./taskwarrior.nix
    ./kitty.nix
    ./tmux.nix
    ./sesh.nix
    ./gh.nix
    ./nix.nix
    ./claude-code.nix
    ./bitwarden-wofi.nix
    ./ssh.nix
    ./lazygit.nix
    ./git-repo-manager.nix
    ./zellij.nix
    ./archives.nix
    ./circumflex.nix
    ./cool-retro-term.nix
    ./auto-shell.nix
    ./worktrunk.nix
    ./workmux.nix
    ./glab.nix
    ./tools.nix
  ];

  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd" #replace cd with z and zi (via cdi)
      ];
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      extraOptions = ["-l" "--icons" "--git" "-a"];
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        show_preview = false;
      };
      flags = ["--disable-up-arrow"];
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [batman];
    };
    bash.enable = true;
    btop.enable = true;
    zsh.shellAliases.vimdiff = "nvim -d";
  };
}
