{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.communication.teams;
in {
  options.features.communication.teams.enable = mkEnableOption "enable teams-for-linux";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      teams-for-linux
      libfido2
    ];

    xdg.configFile."teams-for-linux/config.json".text = builtins.toJSON {
      auth.webauthn.enabled = true;
    };
  };
}
