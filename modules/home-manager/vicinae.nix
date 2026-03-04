{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.vicinae;

  vicinaeDbPath = "${config.xdg.dataHome}/vicinae/vicinae.db";

  extensionSettingsType = types.submodule {
    options = {
      id = mkOption {
        type = types.str;
        description = "Extension ID for database lookup (e.g., 'extension.homeassistant').";
      };

      attributes = mkOption {
        type = types.attrs;
        default = {};
        description = "Preferences/attributes to set for this extension.";
      };

      secrets = mkOption {
        type = types.attrsOf types.path;
        default = {};
        example = literalExpression ''{ "@TOKEN@" = config.sops.secrets."mytoken".path; }'';
        description = "Map of placeholders to secret file paths. Placeholders in attributes will be replaced with secret values.";
      };
    };
  };

  hasSecrets = ext: ext.secrets != {};
  extensionsWithSecrets = filter hasSecrets cfg.extensionSettings;
  extensionsWithoutSecrets = filter (ext: !hasSecrets ext) cfg.extensionSettings;

  sedReplacements = ext:
    concatStringsSep " " (mapAttrsToList
      (placeholder: secretPath: ''| ${pkgs.gnused}/bin/sed "s|${placeholder}|$(cat ${secretPath})|g"'')
      ext.secrets);

  upsertScript = pkgs.writeShellScript "vicinae-upsert-extension-prefs" ''
    set -euo pipefail
    DB_PATH="${vicinaeDbPath}"

    [[ ! -f "$DB_PATH" ]] && exit 0

    upsert() {
      ${pkgs.sqlite}/bin/sqlite3 "$DB_PATH" \
        "INSERT INTO root_provider (id, preference_values, enabled) VALUES ('$1', '$2', 1) ON CONFLICT(id) DO UPDATE SET preference_values = '$2';"
    }

    ${concatMapStringsSep "\n" (ext: ''
        upsert "${ext.id}" '${builtins.toJSON ext.attributes}'
      '')
      extensionsWithoutSecrets}

    ${concatMapStringsSep "\n" (ext: ''
        PREFS=$(echo '${builtins.toJSON ext.attributes}' ${sedReplacements ext})
        upsert "${ext.id}" "$PREFS"
      '')
      extensionsWithSecrets}
  '';
in {
  options.programs.vicinae = {
    setupExtensionPreferences = mkEnableOption "upsert extension preferences to vicinae database on server start";

    extensionSettings = mkOption {
      type = types.listOf extensionSettingsType;
      default = [];
      example = literalExpression ''
        [
          {
            id = "extension.homeassistant";
            attributes = {
              instance = "https://ha.example.com";
              token = "@TOKEN@";
            };
            secrets."@TOKEN@" = config.sops.secrets."applications/homeassistant/token".path;
          }
          {
            id = "extension.hypr-keybinds";
            attributes.keybindsConfigPath = "~/.config/hypr/hyprland.conf";
          }
        ]
      '';
      description = "List of extension settings to upsert into vicinae database.";
    };

    systemdServiceName = mkOption {
      type = types.str;
      default = "vicinae-server";
      description = "Name of the vicinae systemd service to add ExecStartPre to.";
    };
  };

  config = mkIf (cfg.enable && cfg.setupExtensionPreferences && cfg.extensionSettings != []) {
    systemd.user.services.${cfg.systemdServiceName} = {
      Unit.After = mkIf (extensionsWithSecrets != []) ["sops-nix.service"];
      Service.ExecStartPre = mkBefore ["${upsertScript}"];
    };
  };
}
