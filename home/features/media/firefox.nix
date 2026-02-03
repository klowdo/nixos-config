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
          # Linkding
          "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/linkding-extension/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        "3rdparty".Extensions = {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            environment = {
              base = "https://vault.home.flixen.se";
            };
          };
          "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
            baseUrl = "https://linkding.home.flixen.se";
          };
        };
      };
    };
  };
}
