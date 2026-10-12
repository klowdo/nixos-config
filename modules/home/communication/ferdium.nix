{...}: {
  flake.modules.homeManager.ferdium = {pkgs, ...}: {
    home.packages = with pkgs; [
      ferdium
    ];
  };
}
