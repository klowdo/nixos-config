{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rustrover;
  rustroverPkg = pkgs.unstable.jetbrains.rust-rover;
  rustroverVersion = concatStringsSep "." (take 2 (splitString "." rustroverPkg.version));
  marketplace = inputs.nix-jetbrains-plugins.plugins."${pkgs.stdenv.hostPlatform.system}".rust-rover."${rustroverVersion}";
  pluginList = map (id: marketplace.${id}) [
    "IdeaVIM"
    "AceJump"
    "com.joshestein.ideavim-quickscope"
    "dev.ckob.lazygit"
    "com.wakatime.intellij.plugin"
  ];
in {
  options.features.development.tools.rustrover.enable = mkEnableOption "enable RustRover IDE";
  config = mkIf cfg.enable {
    home.packages = [
      # rustroverPkg
      (pkgs.unstable.jetbrains.plugins.addPlugins rustroverPkg pluginList)
    ];

    home.file.".config/JetBrains/RustRover${rustroverVersion}/rustrover64.vmoptions".text = ''
      -Dawt.toolkit.name=WLToolkit
    '';
  };
}
