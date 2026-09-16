{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.wayscriber;
in {
  options.features.desktop.wayscriber.enable =
    mkEnableOption "wayscriber screen annotation overlay";

  config = mkIf cfg.enable {
    home.packages = [pkgs.wayscriber];

    # nixpkgs ships only bin/wayscriber, so the symbolic tray icon never resolves
    xdg.configFile."wayscriber/config.toml".source = (pkgs.formats.toml {}).generate "config.toml" {
      tray.icon_style = "colored";
    };

    features.desktop.which-key.extraMenu = [
      {
        key = "o";
        desc = "Overlay";
        submenu = [
          {
            key = "o";
            desc = "Annotate";
            cmd = "wayscriber --active";
          }
          {
            key = "f";
            desc = "Annotate frozen";
            cmd = "wayscriber --active --freeze";
          }
          {
            key = "w";
            desc = "Whiteboard";
            cmd = "wayscriber --active --mode whiteboard";
          }
        ];
      }
    ];
  };
}
