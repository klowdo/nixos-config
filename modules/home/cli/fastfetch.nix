{...}: {
  flake.modules.homeManager.fastfetch = {pkgs, ...}: {
    home.packages = with pkgs; [fastfetch];
  };
}
