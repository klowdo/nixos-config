{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.extraServices.thyx;
  thyxMalachite = inputs.thyx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        cp $out/share/sddm/themes/thyx/presets/malachite.conf \
           $out/share/sddm/themes/thyx/theme.conf
      '';
  });
in {
  imports = [inputs.thyx.nixosModules.default];

  options.extraServices.thyx.enable = mkEnableOption "thyx SDDM greeter";

  config = mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "hyprland-uwsm";
      sddm.wayland.enable = false;
      sddm.thyx = {
        enable = true;
        package = thyxMalachite;
      };
    };

    security.pam.services.sddm.fprintAuth = true;
  };
}
