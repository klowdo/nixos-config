{...}: {
  flake.modules.homeManager.cool-retro-term = {pkgs, ...}: {
    home.packages = with pkgs; [cool-retro-term];
  };
}
