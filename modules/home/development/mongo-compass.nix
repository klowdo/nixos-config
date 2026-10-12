{...}: {
  flake.modules.homeManager.mongo-compass = {pkgs, ...}: {
    home.packages = [
      pkgs.mongodb-compass
      pkgs.mongodb-tools
      pkgs.mongosh
    ];
  };
}
