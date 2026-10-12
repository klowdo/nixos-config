{...}: {
  flake.modules.homeManager.zellij = {pkgs, ...}: {
    home.packages = with pkgs; [zellij];
  };
}
