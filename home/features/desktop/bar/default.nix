{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.features.desktop.bar;
  enabledBars = filter (x: x) [
    cfg.hyprpanel.enable
    cfg.ashell.enable
    cfg.caelestia.enable
  ];
in {
  imports = [
    ./hyprpanel.nix
    ./ashell.nix
    ./caelestia.nix
  ];

  config = {
    assertions = [
      {
        assertion = length enabledBars <= 1;
        message = ''
          Cannot enable multiple status bars simultaneously.
          Please choose one by enabling only one of:
            - features.desktop.bar.hyprpanel.enable
            - features.desktop.bar.ashell.enable
            - features.desktop.bar.caelestia.enable
        '';
      }
    ];
  };
}
