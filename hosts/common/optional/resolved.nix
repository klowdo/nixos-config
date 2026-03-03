# https://github.com/mrkuz/nixos/blob/master/modules/nixos/resolved.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.extraServices.resolved;
in {
  options.extraServices.resolved.enable = mkEnableOption "enable systemd-resolved";

  config = mkIf cfg.enable {
    services.resolved.enable = true;
  };
}
