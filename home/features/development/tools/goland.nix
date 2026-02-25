{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.goland;
  golandPkg = pkgs.jetbrains-goland;
  golandVersion = concatStringsSep "." (take 2 (splitString "." golandPkg.version));
  pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".goland."${golandVersion}"; [
    IdeaVIM
  ];
in {
  options.features.development.tools.goland.enable = mkEnableOption "enable goland IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.jetbrains.plugins.addPlugins golandPkg pluginList)
    ];
  };
}
