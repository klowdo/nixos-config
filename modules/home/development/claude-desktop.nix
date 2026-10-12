{...}: {
  flake.modules.homeManager.claude-desktop = {pkgs, ...}: {
    home.packages = [
      pkgs.claude-desktop
    ];
  };
}
