{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rider;
  riderpkg = pkgs.unstable.jetbrains.rider;
in {
  options.features.development.tools.rider.enable = mkEnableOption "enable rider IDE";
  config = mkIf cfg.enable {
    home.packages = [
      riderpkg
    ];

    home.file.".local/share/applications/jetbrains-rider.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=JetBrains Rider
      Icon=${riderpkg}/rider/bin/rider.svg
      Exec="${riderpkg}/bin/rider" -Dawt.toolkit.name=WLToolkit %f
      Comment=A cross-platform IDE for .NET
      Categories=Development;IDE;
      Terminal=false
      StartupWMClass=jetbrains-rider
      StartupNotify=true
    '';
  };
}
