{...}: {
  flake.modules.homeManager.glab = {pkgs, ...}: {
    home.packages = [pkgs.unstable.glab];
  };
}
