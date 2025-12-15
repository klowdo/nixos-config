{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.ssh;
in {
  options.features.cli.ssh.enable = mkEnableOption "SSH client with GNOME Keyring integration";

  config =
    mkIf cfg.enable {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "config.d/*"
        ];

        matchBlocks = {
          "*" = {
            addKeysToAgent = "yes";
            forwardAgent = true;
            identityAgent = "\${XDG_RUNTIME_DIR}/keyring/ssh";
          };
          "github.com" = {
            user = "git";
            identityFile = "~/.ssh/id_ed25519
";
          };
        };
        extraConfig = ''
          # Use libsecret for password authentication when needed
          # This allows SSH to integrate with GNOME Keyring for passwords
        '';
      };

      # Add libsecret tools for password management
      home.packages = with pkgs; [
        libsecret # Provides secret-tool command
      ];

      # Helper script for SSH with keyring password lookup
      home.file.".local/bin/ssh-keyring" = {
        text = ''
          #!/usr/bin/env bash
          # SSH wrapper that can retrieve passwords from GNOME Keyring
          # Usage: ssh-keyring user@host
          # First time: store password with: secret-tool store --label="SSH $1" protocol ssh server "$host" user "$user"

          if [[ "$1" == *"@"* ]]; then
            user=$(echo "$1" | cut -d'@' -f1)
            host=$(echo "$1" | cut -d'@' -f2)

            # Try to get password from keyring
            password=$(secret-tool lookup protocol ssh server "$host" user "$user" 2>/dev/null)

            if [ -n "$password" ]; then
              echo "Using password from GNOME Keyring for $user@$host"
              sshpass -p "$password" ssh "$@"
            else
              echo "No password found in keyring for $user@$host"
              echo "Store with: secret-tool store --label=\"SSH $1\" protocol ssh server \"$host\" user \"$user\""
              ssh "$@"
            fi
          else
            ssh "$@"
          fi
        '';
        executable = true;
      };
    };
}
