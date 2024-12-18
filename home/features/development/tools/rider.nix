{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.tools.rider;
  plugins = pkgs.unstable.jetbrains.plugins;
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/jetbrains/default.nix
  riderpkg = pkgs.unstable.jetbrains.rider.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-2024.3.2.tar.gz";
      sha256 = "17ia7g9g8f2h0radgbvcpb7d0h3wmk2rf7dz4819crq0annnnwbw";
    };
    version = "2024.3.2";
    build_number = "243.22562.171";
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
