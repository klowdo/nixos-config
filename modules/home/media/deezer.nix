{...}: {
  flake.modules.homeManager.deezer = {pkgs, ...}: {
    home.packages = with pkgs; [
      deezer-linux
    ];
  };
}
