{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rustrover;
  rustroverPkg = pkgs.unstable.jetbrains.rust-rover.override {forceWayland = true;};
  rustroverVersion = concatStringsSep "." (take 2 (splitString "." rustroverPkg.version));
  pluginList = with inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".rust-rover."${rustroverVersion}"; [
    IdeaVIM
  ];
in {
  options.features.development.tools.rustrover.enable = mkEnableOption "enable RustRover IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.jetbrains.plugins.addPlugins rustroverPkg pluginList)
    ];

    home.file.".config/JetBrains/RustRover${rustroverVersion}/rustrover64.vmoptions".text = ''
      -Dawt.toolkit.name=WLToolkit
      -Dsun.java2d.xrender.enabled=true
      -Dsun.java2d.pmoffscreen=false
    '';
  };
}
