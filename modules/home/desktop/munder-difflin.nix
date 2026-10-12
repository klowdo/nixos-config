{...}: {
  flake.modules.homeManager.munder-difflin = {pkgs, ...}: {
    home.packages = [pkgs.munder-difflin];
  };
}
