{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    withPython3 = true;
  };
  # to get lazyvim work with nix https://nixalted.com/
  # home.file = {
  # ".config/nvim".source = ./config;
  #
  # };

  home.packages = with pkgs; [
    # CC
    gcc
    gnumake
    cmake
    autoconf
    automake
    libtool
  ];
}
