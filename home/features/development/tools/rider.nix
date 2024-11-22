{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rider;
  plugins = pkgs.unstable.jetbrains.plugins;
  riderpkg = pkgs.unstable.jetbrains.rider.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-2024.3.tar.gz";
      sha256 = "ef9b61c18851b6f3ef2bfa3fe147b34ac191622f65a41f2b53b3a609f9bff360";
    };
    version = "2024.3";
    build_number = "243.21565.191";
  });
in {
  options.features.development.tools.rider.enable = mkEnableOption "enable rider IDE";
  config = mkIf cfg.enable {
    home.packages = [
      (plugins.addPlugins riderpkg ["github-copilot" "ideavim"])
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
