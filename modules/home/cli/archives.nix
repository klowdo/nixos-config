{...}: {
  flake.modules.homeManager.archives = {pkgs, ...}: {
    home.packages = with pkgs; [
      unzip
      unrar
      p7zip
    ];
  };
}
