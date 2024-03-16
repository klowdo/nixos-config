{ ... }:
{

  programs.neovim = {
  enable = true;
   defaultEditor = true;

    viAlias = true;
  vimAlias = true;
};
# to get lazyvim work with nix https://nixalted.com/
# home.file = {
# ".config/nvim".source = ./config;
#
# };
}
