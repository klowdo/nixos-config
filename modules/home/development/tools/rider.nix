{inputs, ...}: {
  flake.modules.homeManager.rider = {
    lib,
    pkgs,
    ...
  }:
    with lib; let
      inherit (pkgs.unstable.jetbrains) plugins;
      riderpkg = pkgs.jetbrains.rider;
      riderVersion = concatStringsSep "." (take 2 (splitString "." riderpkg.version));
      pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".rider."${riderVersion}"; [
        IdeaVIM
      ];
    in {
      home.packages = [
        (plugins.addPlugins riderpkg pluginList)
      ];
    };
}
