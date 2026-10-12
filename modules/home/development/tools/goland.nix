{inputs, ...}: {
  flake.modules.homeManager.goland = {
    lib,
    pkgs,
    ...
  }:
    with lib; let
      golandPkg = pkgs.jetbrains.goland;
      golandVersion = concatStringsSep "." (take 2 (splitString "." golandPkg.version));
      pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".goland."${golandVersion}"; [
        IdeaVIM
      ];
    in {
      home.packages = [
        (pkgs.jetbrains.plugins.addPlugins golandPkg pluginList)
      ];
    };
}
