{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.password-store;
in {
  options.features.cli.password-store = {
    enable = mkEnableOption "enable password-store";

    gpgId = mkOption {
      type = types.str;
      default = "klowdo@klowdo.dev";
      description = "GPG ID to use for password-store encryption";
    };

    gitRepo = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Git repository URL for password store synchronization";
    };
  };

  config = mkIf cfg.enable {
    # GPG configuration is handled by features.cli.gpg module
    # Enable it alongside password-store for full functionality
    assertions = [
      {
        assertion = config.features.cli.gpg.enable;
        message = "features.cli.gpg must be enabled when using password-store (GPG is required for encryption)";
      }
    ];

    home.packages = with pkgs; [
      # Clipboard integration
      xclip
      wl-clipboard # Wayland clipboard
    ];

    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts:
        with exts; [
          pass-otp
          pass-tomb
          pass-update
          pass-audit
          pass-genphrase
        ]);

      settings =
        {
          # Password store directory
          PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";

          # GPG settings
          PASSWORD_STORE_GPG_OPTS = "--quiet --yes --compress-algo 1 --cipher-algo AES256 --digest-algo SHA512";

          # Clipboard settings (clear after 45 seconds)
          PASSWORD_STORE_CLIP_TIME = "45";

          # Generate passwords with symbols by default
          PASSWORD_STORE_GENERATED_LENGTH = "32";
          PASSWORD_STORE_CHARACTER_SET = "[:graph:]";

          # Enable git integration
          PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
        }
        // optionalAttrs (cfg.gitRepo != null) {
          # Git repository for syncing
          PASSWORD_STORE_GIT = cfg.gitRepo;
        };
    };

    # Shell aliases for convenience
    home.shellAliases = {
      # Basic pass commands with common options
      "p" = "pass";
      "pg" = "pass generate";
      "pe" = "pass edit";
      "pi" = "pass insert";
      "pc" = "pass show -c"; # Copy to clipboard

      # OTP commands
      "pass-otp" = "pass otp";
      "pass-qr" = "pass otp uri -q"; # Show QR code for OTP

      # Audit and maintenance
      "pass-audit" = "pass audit";
      "pass-update" = "pass update";
    };

    # Desktop integration
    xdg.desktopEntries = {
      password-store = {
        name = "Password Store";
        comment = "Manage passwords with pass";
        exec = "${pkgs.kitty}/bin/kitty -e ${pkgs.pass}/bin/pass";
        icon = "dialog-password";
        categories = ["Utility" "Security"];
      };
    };
  };
}
