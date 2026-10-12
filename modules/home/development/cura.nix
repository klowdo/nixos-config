{...}: {
  flake.modules.homeManager.cura = {pkgs, ...}: {
    home.packages = [
      pkgs.unstable.cura-appimage
    ];
  };
}
