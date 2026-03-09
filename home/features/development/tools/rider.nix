{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rider;
  inherit (pkgs.unstable.jetbrains) plugins;
  riderpkg = pkgs.jetbrains-rider;
  riderVersion = concatStringsSep "." (take 2 (splitString "." riderpkg.version));
  pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".rider."${riderVersion}"; [
    IdeaVIM
    Mermaid
  ];
in {
  options.features.development.tools.rider.enable = mkEnableOption "enable rider IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (plugins.addPlugins riderpkg pluginList)
    ];
  };
}
