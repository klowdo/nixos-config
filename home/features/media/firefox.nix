{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.media.firefox;
in {
  options.features.media.firefox.enable = mkEnableOption "enable firefox browser";

  config = mkIf cfg.enable {
    stylix.targets.firefox.profileNames = ["default"];
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            };
            "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
            };
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
            };
            "floccus@handmadeideas.org" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
            };
            "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/linkding-extension/latest.xpi";
            };
          };
          "3rdparty".Extensions = {
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              environment.base = "https://vault.home.flixen.se";
            };
            "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
              baseUrl = "https://linkding.home.flixen.se";
            };
          };
        };
      };
      profiles.default = {
        id = 0;
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://home.flixen.se";
          "browser.startup.page" = 1;
          "signon.rememberSignons" = false;
          "signon.autofillForms" = false;
        };
      };
    };
  };
}
