{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./zsh.nix
    ./fzf.nix
    ./neofetch.nix
    ./yazi.nix
    ./password-store.nix
    ./nh.nix
    ./taskwarrior.nix
    ./kitty.nix
    ./tmux.nix
    ./gh.nix
    ./nix.nix
    ./superclaude.nix
    ./claude-code.nix
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
    ]
    ++ [
      pkgs.unstable.isd
      inputs.kixvim.packages.${system}.default
    ];

  home.sessionVariables = {EDITOR = "nvim";};

  programs = {
    zsh.shellAliases.vimdiff = "nvim -d";
  };
  programs.lazygit = {
    enable = true;
    package = pkgs.unstable.lazygit;
  };
}
