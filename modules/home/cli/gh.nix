{...}: {
  flake.modules.homeManager.gh = {pkgs, ...}: {
    home.packages = with pkgs; [
      gh
      gh-dash
    ];
  };
}
