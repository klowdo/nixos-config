{inputs, ...}: {
  flake.modules.homeManager.rustrover = {
    lib,
    pkgs,
    ...
  }:
    with lib; let
      rustroverPkg = pkgs.jetbrains.rust-rover;
      rustroverVersion = concatStringsSep "." (take 2 (splitString "." rustroverPkg.version));
      pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".rust-rover."${rustroverVersion}"; [
        IdeaVIM
      ];
    in {
      home.packages = [
        (pkgs.jetbrains.plugins.addPlugins rustroverPkg pluginList)
      ];

      home.file.".config/JetBrains/RustRover${rustroverVersion}/rustrover64.vmoptions".text = ''
        -Dawt.toolkit.name=WLToolkit
      '';
    };
}
