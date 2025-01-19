{pkgs, ...}: {
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

  programs.bat = {enable = true;};

  home.packages = with pkgs; [
    coreutils
    fd
    htop
    httpie
    jq
    procs
    ripgrep
    tldr
    zip
  ];
  programs.lazygit = {
    enable = true;
  };
}
