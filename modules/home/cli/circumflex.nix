{...}: {
  flake.modules.homeManager.circumflex = {pkgs, ...}: {
    home.packages = with pkgs; [circumflex];
  };
}
