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
  riderpkg =
    pkgs.unstable.jetbrains.rider.overrideAttrs
    (_old: {
      src = pkgs.fetchurl {
        url = "https://download.jetbrains.com/rider/JetBrains.Rider-2024.3.6.tar.gz";
        hash = "sha256-H5258/kMcf5Hbj4XrHi+n8yYLj8BfFmPYxtc1gDm2kM=";
      };
      # https://www.jetbrains.com/rider/download/other.html
      version = "2024.3.6";
      build_number = "243.25659.34";

      postInstall = ''
        (
          cd $out/rider

          ls -d $PWD/plugins/cidr-debugger-plugin/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
          xargs patchelf \
            --replace-needed libssl.so.10 libssl.so \
            --replace-needed libcrypto.so.10 libcrypto.so \
            --replace-needed libcrypt.so.1 libcrypt.so

          for dir in lib/ReSharperHost/linux-*; do
            rm -rf $dir/dotnet
            ln -s ${pkgs.unstable.dotnet-sdk_8.unwrapped}/share/dotnet $dir/dotnet
          done
        )
      '';
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
