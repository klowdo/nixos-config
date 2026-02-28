{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.media.music-assistant;
  inherit ((inputs.nix-webapps.overlays.default pkgs pkgs).nix-webapp-lib) mkFirefoxApp;
in {
  options.features.media.music-assistant = {
    enable = mkEnableOption "enable Music Assistant PWA";

    url = mkOption {
      type = types.str;
      default = "http://localhost:8095";
      description = "URL of your Music Assistant instance";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefoxpwa

      (mkFirefoxApp {
        name = "music-assistant";
        url = "${cfg.url}";

        prefs = {
          # Enable media session API and hardware media keys
          "media.hardwaremediakeys.enabled" = true;
          "dom.media.mediasession.enabled" = true;
          # Enable media control notifications
          "media.mediasession.enabled" = true;
          "media.audioFocus.enabled" = true;
          # Disable Firefox's own media controls to avoid conflicts
          "media.videocontrols.picture-in-picture.enabled" = false;
          # Keep session alive and minimize to system tray behavior
          "browser.sessionstore.resume_from_crash" = true;
          "browser.warnOnQuit" = false;
          "browser.showQuitWarning" = false;
          # Enable notifications for better media integration
          "dom.webnotifications.enabled" = true;
        };

        extraArgs = [];

        makeDesktopItemArgs = {
          name = "Music Assistant";
          genericName = "Music Controller";
          comment = "Music Assistant Web App";
          icon = ../../../lib/icons/music-assistant.png;
          terminal = false;
          categories = ["AudioVideo" "Audio" "Player"];
          startupNotify = true;
          keywords = ["Music" "Audio" "Player" "MPRIS"];
        };
      })
    ];

    home.file.".local/share/icons/music-assistant.png".source = ../../../lib/icons/music-assistant.png;

    # xdg.desktopEntries.music-assistant = {
    #   name = "Music Assistant";
    #   genericName = "Music Controller";
    #   comment = "Music Assistant Web App";
    #   exec = "${pkgs.firefoxpwa}/bin/firefoxpwa site launch ${cfg.url}";
    #   icon = "music-assistant";
    #   terminal = false;
    #   categories = ["AudioVideo" "Audio" "Player"];
    #   startupNotify = true;
    # };
    #
    # environment.systemPackages = [
    # ];
  };
}
