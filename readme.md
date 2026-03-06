# NixOS Configuration

![NixOS](https://img.shields.io/badge/NixOS-configuration-blue?logo=nixos)
![NH](https://img.shields.io/badge/Built%20with-NH-blueviolet)
![License](https://img.shields.io/badge/license-MIT-green)
![Nix Check](https://github.com/klowdo/nixos-config/actions/workflows/check.yml/badge.svg)

Declarative NixOS configuration using Nix flakes, Home Manager, and Hyprland. Secrets managed with SOPS-nix (YubiKey + TPM 2.0 support), disk partitioning via Disko, and themed with Stylix + Catppuccin.

## Quick Start

```bash
git clone https://github.com/klowdo/nixos-config.git
cd nixos-config
nh os switch
```

For fresh installations, see [docs/installation.md](./docs/installation.md).

## Hosts

| Host | Description |
|------|-------------|
| `dellicious` | Dell XPS 15 -- primary workstation, Intel CPU, Hyprland, 3456x2160 |
| `virt-nix` | Virtual machine for testing |
| `iso` | Custom NixOS installer ISO with disko and YubiKey support |
| `iso-minimal` | Minimal installer ISO variant |

## Directory Structure

```
.
├── flake.nix          # Entry point -- inputs and host definitions
├── hosts/
│   ├── common/        # Shared system configuration (core + optional)
│   ├── dellicious/    # Dell XPS 15 host
│   ├── virt-nix/      # VM host
│   └── iso/           # Installer ISO
├── home/
│   ├── features/      # Modular feature sets
│   └── klowdo/        # User-specific config
├── modules/           # Custom NixOS and Home Manager modules
├── overlays/          # Package overlays
├── pkgs/              # Custom package definitions
├── lib/               # Helper functions
├── scripts/           # Management scripts
└── docs/              # Documentation
```

## Features

Home Manager configuration is organized into feature modules under `home/features/`:

| Category | Contents |
|----------|----------|
| `cli` | Terminal tools -- kitty, zsh, tmux, fzf, yazi |
| `desktop` | Hyprland, HyprPanel, screen locking, notifications |
| `development` | .NET, Rider, LibreOffice |
| `media` | Spotify (Spicetify), Zathura |
| `communication` | Discord, Zoom |
| `gaming` | Game-related packages |
| `hardware` | Hardware-specific configuration |
| `sync` | File synchronization |

## Key Technologies

- **NixOS 25.11** with unstable overlay
- **Home Manager** for user environment
- **Hyprland** Wayland compositor
- **SOPS-nix** with age encryption (YubiKey + TPM 2.0)
- **Disko** for declarative disk partitioning
- **Stylix + Catppuccin** theming
- **NH** for streamlined builds

## Commands

Build and deploy with NH:

```bash
nh os switch    # Rebuild and switch to new configuration
nh os test      # Test without applying
```

Run `just --list` for all available commands, including secrets management, ISO builds, and development tooling.

## Documentation

- [Installation guide](./docs/installation.md)
- [CLAUDE.md](./CLAUDE.md) -- full command reference and architecture details

## License

This project is licensed under the MIT License.
