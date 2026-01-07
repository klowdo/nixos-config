{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.features.desktop.bar;
in {
  imports = [
    ./hyprpanel.nix
    ./ashell.nix
  ];

  config = {
    assertions = [
      {
        assertion = !(cfg.hyprpanel.enable && cfg.ashell.enable);
        message = ''
          Cannot enable both hyprpanel and ashell simultaneously.
          Please choose one status bar by enabling either:
            - features.desktop.bar.hyprpanel.enable
            - features.desktop.bar.ashell.enable
        '';
      }
    ];
  };
}
