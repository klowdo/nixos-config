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

  config = mkIf cfg.enable {
    sops.secrets = {
      "ssh/customer-1/config" = {
        path = "${config.home.homeDirectory}/.ssh/config.d/customer-1.conf";
        mode = "0440";
      };
      "ssh/customer-1/hostkey" = {
        path = "${config.home.homeDirectory}/.ssh/known_hosts.d/customer-1";
        mode = "0440";
      };
    };
    home.file = {
      ".ssh/known_hosts.d/public" = {
        text = ''
          github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
          github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
        '';
      };

      # Helper script for SSH with keyring password lookup
      ".local/bin/ssh-keyring" = {
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
    # sops.templates = {
    #   # "ssh-customer-1-config" = {
    #   #   content = config.sops.placeholder."ssh/customer-1/config";
    #   #   path = "${config.home.homeDirectory}/.ssh/config.d/customer-1.conf";
    #   #   mode = "0600";
    #   # };
    #
    #   "ssh-known-hosts-declarative" = {
    #     content = ''
    #       # GitHub
    #       github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    #       github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
    #
    #       # Customer hosts (from SOPS)
    #       ${config.sops.placeholder."ssh/customer-1/hostkey"}
    #     '';
    #     path = "${config.home.homeDirectory}/.ssh/known_hosts.d/declarative";
    #     mode = "0600";
    #   };
    # };

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
          extraOptions = {
            UserKnownHostsFile = "~/.ssh/known_hosts";
            KnownHostsCommand = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/cat ~/.ssh/known_hosts.d/* 2>/dev/null || true'";
          };
        };
        "github.com" = {
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
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
  };
}
