{pkgs, ...}: {
  # https://nix-community.github.io/nixvim/plugins/image/index.html
  programs.nixvim = {
    extraLuaPackages = ps: [ps.magick];
    extraPackages = [pkgs.imagemagick];
    plugins.image = {
      enable = true;
    };
  };
}
