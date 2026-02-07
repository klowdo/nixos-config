# Home Manager impermanence configuration
#
# Persists user-level state directories and files that are needed across reboots.
# Works in conjunction with the NixOS system-level impermanence module.
#
# The home directory is mounted as tmpfs; only directories listed here survive reboots.
# State managed by Home Manager (dotfiles, configs) is recreated on activation,
# so only runtime/application data directories need explicit persistence.
{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.impermanence;
  hmPersistPath = "${cfg.persistPath}/home/${config.home.username}";
in {
  imports = [inputs.impermanence.homeManagerModules.impermanence];

  options.features.impermanence = {
    enable = mkEnableOption "Home Manager impermanence (persist user state across reboots)";

    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Path to the persistent storage mount point (same as system-level)";
    };
  };

  config = mkIf cfg.enable {
    home.persistence.${hmPersistPath} = {
      allowOther = true;

      directories = [
        # ── SSH & security ──
        ".ssh" # SSH keys, known_hosts, config
        ".gnupg" # GPG keyrings, trust database, agent state
        ".password-store" # Pass password store (GPG-encrypted)
        ".local/share/keyrings" # GNOME Keyring data (also synced via Syncthing)
        ".config/sops/age" # SOPS age decryption keys (software + hardware identity files)

        # ── Shell & terminal ──
        ".local/share/zsh" # Zsh history
        ".local/state/zsh" # Zsh state (completions cache, etc.)

        # ── Browser ──
        ".mozilla/firefox" # Firefox profiles, bookmarks, history, extensions, sessions

        # ── Email ──
        "Mail" # mbsync mail directories (gmail, office365)
        ".cache/neomutt" # Neomutt header/body cache and certificates

        # ── Development ──
        ".dotfiles" # NixOS config repository
        "dev" # Development projects (github/, work/)
        ".local/share/docker" # Rootless Docker data (images, containers, volumes)
        ".docker" # Docker CLI config, buildx state
        ".config/JetBrains" # JetBrains IDE settings and plugins
        ".local/share/JetBrains" # JetBrains IDE caches, indexes, logs
        ".java/.userPrefs" # Java preference backing store
        ".dotnet" # .NET tools, NuGet cache
        ".nuget" # NuGet package cache
        ".config/NuGet" # NuGet configuration
        ".local/share/go" # Go module cache
        ".cache/go-build" # Go build cache
        ".config/devenv" # devenv state

        # ── Sync ──
        ".local/share/syncthing" # Syncthing database, identity, config
        "Documents" # Syncthing-synced documents
        "Pictures" # Syncthing-synced photos
        "Downloads" # User downloads
        "Videos" # User videos
        "Music" # User music

        # ── Communication ──
        ".config/vesktop" # Vesktop/Discord data and Vencord plugins
        ".config/Slack" # Slack desktop app data

        # ── Media ──
        ".config/spotify" # Spotify cache and settings
        ".config/BraveSoftware" # Brave browser data

        # ── Desktop ──
        ".local/share/cliphist" # Clipboard history database
        ".config/hypr" # Hyprland runtime session state

        # ── Gaming ──
        ".steam" # Steam client, installed games, save data
        ".local/share/Steam" # Steam library data
        ".config/heroic" # Heroic Games Launcher config and data
        ".local/share/heroic" # Heroic Games Launcher game data

        # ── Password manager ──
        ".config/Bitwarden" # Bitwarden Desktop vault cache

        # ── Productivity ──
        ".config/libreoffice" # LibreOffice user profile
        ".local/share/taskwarrior" # Taskwarrior task database

        # ── AI/Claude ──
        ".claude" # Claude Code config, OAuth tokens, memory

        # ── Nix ──
        ".local/state/nix" # Nix profile state
        ".cache/nix" # Nix evaluation cache

        # ── Flatpak ──
        ".var/app" # Flatpak per-app sandboxed data

        # ── Misc state ──
        ".config/dconf" # GNOME/GTK application settings database
        ".local/share/direnv" # direnv allow database
        ".config/pulse" # PulseAudio/PipeWire client config
        ".local/state/wireplumber" # WirePlumber audio routing state

        # ── 3D Printing ──
        ".config/cura" # Cura slicer profiles and settings
        ".local/share/orca-slicer" # OrcaSlicer data
        ".config/BambuStudio" # Bambu Studio slicer data

        # ── Time tracking ──
        ".wakatime" # WakaTime/Wakapi local state
      ];

      files = [
        ".git-credentials" # Git credential store (from SOPS)
        ".wakatime.cfg" # WakaTime configuration (from SOPS)
        ".local/share/recently-used.xbel" # Recent files (used by file pickers)
      ];
    };
  };
}
