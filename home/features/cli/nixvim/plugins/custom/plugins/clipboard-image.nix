{pkgs, ...}: {
  # https://nix-community.github.io/nixvim/plugins/clipboard-image/index.html
  programs.nixvim = {
    plugins.clipboard-image = {
      enable = true;
      clipboardPackage = pkgs.wl-clipboard;
    };
  };
}
