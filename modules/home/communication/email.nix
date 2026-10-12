{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.email = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [flake.modules.homeManager.sops];
    accounts.email = {
      maildirBasePath = "Mail";

      accounts = {
        gmail = {
          primary = true;
          address = config.userConfig.email;
          userName = config.userConfig.email;
          realName = config.userConfig.fullName;

          imap = {
            host = "imap.gmail.com";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "smtp.gmail.com";
            port = 587;
            tls = {
              enable = true;
              useStartTls = true;
            };
          };

          maildir.path = "gmail";

          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };

          passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/gmail-password".path}";
        };

        office365 = {
          address = "felix@flixen.se";
          userName = "felix@flixen.se";
          realName = config.userConfig.fullName;

          imap = {
            host = "outlook.office365.com";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "smtp.office365.com";
            port = 587;
            tls = {
              enable = true;
              useStartTls = true;
            };
          };

          maildir.path = "office365";

          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };

          passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/office365-password".path}";
        };
      };
    };

    programs.mbsync.enable = true;
    services.mbsync.enable = true;

    home.packages = with pkgs; [
      isync # For offline mail sync (mbsync)
      msmtp # For sending mail
    ];

    home.activation.mailSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ~/Mail/{gmail,office365}
    '';
  };
}
