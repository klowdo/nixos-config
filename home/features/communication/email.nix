{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.communication.email;
in {
  options.features.communication.email.enable = mkEnableOption "enable email accounts";

  config = mkIf cfg.enable {
    # Email accounts configuration
    accounts.email = {
      maildirBasePath = "Mail";

      accounts = {
        gmail = {
          primary = true;
          address = "klowdo.fs@gmail.com";
          userName = "klowdo.fs@gmail.com";
          realName = "Felix Svensson";

          # IMAP settings for Gmail
          imap = {
            host = "imap.gmail.com";
            port = 993;
            tls.enable = true;
          };

          # SMTP settings for Gmail
          smtp = {
            host = "smtp.gmail.com";
            port = 587;
            tls = {
              enable = true;
              useStartTls = true;
            };
          };

          # Enable maildir for offline storage
          maildir.path = "gmail";

          # Enable mbsync for this account
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };

          # Use SOPS for password
          passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/gmail-password".path}";
        };

        office365 = {
          address = "felix@flixen.se";
          userName = "felix@flixen.se";
          realName = "Felix Svensson";

          # IMAP settings for Office365
          imap = {
            host = "outlook.office365.com";
            port = 993;
            tls.enable = true;
          };

          # SMTP settings for Office365
          smtp = {
            host = "smtp.office365.com";
            port = 587;
            tls = {
              enable = true;
              useStartTls = true;
            };
          };

          # Enable maildir for offline storage
          maildir.path = "office365";

          # Enable mbsync for this account
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };

          # Use SOPS for password
          passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/office365-password".path}";
        };
      };
    };

    # Enable mbsync program and service
    programs.mbsync.enable = true;
    services.mbsync.enable = true;

    # Required packages
    home.packages = with pkgs; [
      isync # For offline mail sync (mbsync)
      msmtp # For sending mail
    ];

    # Create mail directories
    home.activation.mailSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ~/Mail/{gmail,office365}
    '';
  };
}