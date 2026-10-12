{...}: {
  flake.modules.homeManager.orca = {pkgs, ...}: {
    home.packages = [
      pkgs.unstable.orca-slicer
    ];
  };
}
