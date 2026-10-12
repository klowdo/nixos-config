{...}: {
  flake.modules.homeManager.super-slicer = {pkgs, ...}: {
    home.packages = [
      pkgs.unstable.super-slicer
    ];
  };
}
