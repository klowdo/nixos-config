{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rustrover;
  rustroverPkg = pkgs.jetbrains.rust-rover.override {forceWayland = true;};
  rustroverVersion = concatStringsSep "." (take 2 (splitString "." rustroverPkg.version));
in {
  options.features.development.tools.rustrover.enable = mkEnableOption "enable RustRover IDE";
  config = mkIf cfg.enable {
    home.packages = [
      rustroverPkg
    ];

    home.file.".config/JetBrains/RustRover${rustroverVersion}/rustrover64.vmoptions".text = ''
      -Dawt.toolkit.name=WLToolkit
    '';
  };
}
