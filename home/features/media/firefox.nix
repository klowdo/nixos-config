{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.media.firefox;
in {
  options.features.media.firefox.enable = mkEnableOption "enable firefox browser";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        ExtensionSettings = {
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # I don't care about cookies
          "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        "3rdparty".Extensions."{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          environment = {
            base = "https://vault.home.flixen.se";
          };
        };
      };
    };
  };
}
