{inputs, ...}: {
  flake.modules.homeManager.music-assistant = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.media.music-assistant;
      inherit ((inputs.nix-webapps.overlays.default pkgs pkgs).nix-webapp-lib) mkFirefoxApp;
    in {
      options.features.media.music-assistant = {
        url = mkOption {
          type = types.str;
          default = "http://localhost:8095";
          description = "URL of your Music Assistant instance";
        };
      };
      config = {
        home.packages = with pkgs; [
          firefoxpwa

          (mkFirefoxApp {
            name = "music-assistant";
            url = "${cfg.url}";

            prefs = {
              "media.hardwaremediakeys.enabled" = true;
              "dom.media.mediasession.enabled" = true;
              "media.mediasession.enabled" = true;
              "media.audioFocus.enabled" = true;
              "media.videocontrols.picture-in-picture.enabled" = false;
              "browser.sessionstore.resume_from_crash" = true;
              "browser.warnOnQuit" = false;
              "browser.showQuitWarning" = false;
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
      };
    };
}
