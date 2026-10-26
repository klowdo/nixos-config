{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.extraServices.onepassword;
in {
  options.extraServices.onepassword = {
    enable = mkEnableOption "enable onepassword cli and desktop";
  };

  config = mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [config.userConfig.username];
    };
  };
}
