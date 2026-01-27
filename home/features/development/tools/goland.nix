{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.goland;
  year = "2025";
  version = "3";
  patch = ".1.1"; #".2"
  # Get JetBrains plugins from the flake
  # https://www.jetbrains.com/go/download/other.html
  golandPkg =
    (pkgs.unstable.jetbrains.goland.override {
      forceWayland = true;
    }).overrideAttrs
    (_old: {
      src = pkgs.fetchurl {
        url = "https://download.jetbrains.com/go/goland-${year}.${version}${patch}.tar.gz";
        hash = "sha256-+4A+rTMwiXjKuBI2dUf90F9KUFaGlB2xgO+BX09WnWw=";
      };
      # https://www.jetbrains.com/rider/download/other.html
      version = "${year}.${version}${patch}";
      build_number = "253.29346.379";
    });
  # golandVersion = "${year}.${version}";
  pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".goland."${year}.${version}"; [
    IdeaVIM
  ];
in {
  options.features.development.tools.goland.enable = mkEnableOption "enable goland IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.jetbrains.plugins.addPlugins golandPkg pluginList)
    ];
    # home.file.".config/JetBrains/GoLand${golandVersion}/goland64.vmoptions".text = ''
    #   # custom GoLand VM options (expand/override 'bin/goland64.vmoptions')
    #
    #   -Dawt.toolkit.name=WLToolkit
    # '';
  };
}
