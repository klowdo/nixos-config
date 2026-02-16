{
  pkgs,
  inputs,
  ...
}: {
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
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd" #replace cd with z and zi (via cdi)
    ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraOptions = ["-l" "--icons" "--git" "-a"];
  };

  programs.bat = {
    enable = true;
    extraPackages = builtins.attrValues {
      inherit
        (pkgs.bat-extras)
        batgrep # search through and highlight files using ripgrep
        batdiff # Diff a file against the current git index, or display the diff between to files
        batman
        ; # read manpages using bat as the formatter
    };
  };

  home.packages = with pkgs;
    [
      coreutils
      fd
      htop
      httpie
      jq
      procs
      ripgrep
      tldr
      zip
      wishlist
      unp
      unstable.witr
    ]
    ++ [
      pkgs.unstable.isd
      inputs.kixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  home.sessionVariables = {EDITOR = "nvim";};

  programs = {
    zsh.shellAliases.vimdiff = "nvim -d";
  };
}
