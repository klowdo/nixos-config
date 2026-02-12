{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.gpg;
in {
  options.features.cli.gpg = {
    enable = mkEnableOption "GPG with YubiKey smartcard support";

    keyId = mkOption {
      type = types.str;
      default = "";
      description = "GPG key ID or fingerprint used for signing (git commits, tags, etc.)";
    };

    enableGitSigning = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GPG signing for git commits and tags";
    };

    enableSshSupport = mkOption {
      type = types.bool;
      default = false;
      description = "Enable SSH authentication via GPG agent (uses GPG keys instead of ssh-agent)";
    };

    defaultCacheTtl = mkOption {
      type = types.int;
      default = 28800; # 8 hours
      description = "Default cache TTL for GPG agent (seconds)";
    };

    maxCacheTtl = mkOption {
      type = types.int;
      default = 86400; # 24 hours
      description = "Maximum cache TTL for GPG agent (seconds)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
      pinentry-gtk2 # GUI pinentry for GPG prompts
      paperkey # Extract secret key for paper backup
      pgpdump # Inspect GPG packet structure
      qrencode # Generate QR codes for key transfer
    ];

    programs.gpg = {
      enable = true;

      settings = {
        # Use GPG agent for passphrase caching and smartcard access
        use-agent = true;

        # Strong cipher preferences
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";

        # Default algorithms for new keys
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";

        # Disable weak algorithms
        weak-digest = "SHA1";

        # Key server
        keyserver = "hkps://keys.openpgp.org";
        keyserver-options = "auto-key-retrieve no-honor-keyserver-url";

        # Display preferences
        keyid-format = "0xlong";
        with-fingerprint = true;
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";

        # Require cross-certification on subkeys
        require-cross-certification = true;

        # Use UTF-8 charset
        charset = "utf-8";
        fixed-list-mode = true;
      };

      # Smartcard daemon settings for YubiKey
      scdaemonSettings = {
        # Use PC/SC daemon (pcscd) instead of built-in CCID
        # Required for YubiKey when pcscd is running
        disable-ccid = true;
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = cfg.enableSshSupport;
      defaultCacheTtl = cfg.defaultCacheTtl;
      maxCacheTtl = cfg.maxCacheTtl;

      # GUI pinentry for passphrase prompts
      pinentryPackage = pkgs.pinentry-gtk2;

      extraConfig = ''
        # Allow tools to preset passphrases into the agent cache
        allow-preset-passphrase
        # Allow loopback pinentry (for scripts)
        allow-loopback-pinentry
      '';
    };

    # Shell aliases for GPG operations
    home.shellAliases = {
      # Key management
      "gpg-list" = "gpg --list-keys --keyid-format 0xlong";
      "gpg-list-secret" = "gpg --list-secret-keys --keyid-format 0xlong";

      # Smartcard / YubiKey
      "gpg-card" = "gpg --card-status";
      "gpg-card-edit" = "gpg --card-edit";

      # Reload agent (useful after YubiKey insert/remove)
      "gpg-reload" = "gpg-connect-agent reloadagent /bye";
    };

    # Ensure GPG agent socket directory exists
    # and set GPG_TTY for proper pinentry display
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
    };

    # Auto-start gpg-agent via systemd
    systemd.user.services.gpg-agent-symlink = {
      Unit.Description = "Create GPG agent socket symlink";
      Install.WantedBy = ["default.target"];
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'gpgconf --create-socketdir || true'";
        RemainAfterExit = true;
      };
    };
  };
}
