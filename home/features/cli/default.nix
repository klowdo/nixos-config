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

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      show_preview = false;
    };
    flags = ["--disable-up-arrow"];
  };

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [batman];
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
      duf
      ncdu
      pciutils
      appimage-run
      virt-viewer
    ]
    ++ [
      pkgs.unstable.isd
      inputs.kixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  home.sessionVariables = {EDITOR = "nvim";};

  programs = {
    bash.enable = true;
    btop.enable = true;
    zsh.shellAliases.vimdiff = "nvim -d";
  };
}
