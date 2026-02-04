{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.sync.syncthing;
in {
  options.features.sync.syncthing = {
    enable = mkEnableOption "Syncthing file synchronization";

    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "Address and port for the Syncthing web GUI";
    };

    tray.enable = mkEnableOption "Syncthing tray icon";
  };

  config = mkIf cfg.enable {
    sops.secrets."syncthing/cert" = {
      mode = "0600";
    };
    sops.secrets."syncthing/key" = {
      mode = "0600";
    };
    sops.secrets."syncthing/gui-password" = {
      mode = "0600";
    };

    services.syncthing = {
      enable = true;
      cert = config.sops.secrets."syncthing/cert".path;
      key = config.sops.secrets."syncthing/key".path;
      passwordFile = config.sops.secrets."syncthing/gui-password".path;
      inherit (cfg) guiAddress;
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = {
          "pve-server" = {
            id = "7AQJT3J-3HHVSWQ-XCDTDNM-AU5AEKR-NUILXNJ-JJ3HC32-ZXLL56L-VKISOQP";
          };
        };
        folders = {
          "Documents" = {
            id = "documents";
            path = "~/Documents";
            devices = ["pve-server"];
            enable = true;
            versioning = {
              type = "simple";
              params.keep = "5";
            };
          };
          "Pictures" = {
            id = "pictures";
            path = "~/Pictures";
            devices = ["pve-server"];
            enable = true;
            versioning = {
              type = "simple";
              params.keep = "5";
            };
          };
          "Keyrings" = {
            id = "keyrings";
            path = "~/.local/share/keyrings";
            devices = ["pve-server"];
            enable = true;
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
        };
        gui = {
          user = "klowdo";
          insecureAdminAccess = true;
        };
        options = {
          urAccepted = -1;
          relaysEnabled = true;
          localAnnounceEnabled = true;
        };
      };

      tray = mkIf cfg.tray.enable {
        enable = true;
      };
    };
  };
}
