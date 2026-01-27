# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a sophisticated NixOS dotfiles configuration using Nix flakes that manages both system-level (NixOS) and user-level (Home Manager) configurations. The repository follows a modular, feature-based architecture with two hosts: `dellicious` (Dell XPS 15) and `virt-nix` (VM).

## Common Commands

### Primary Build & Deploy (NH Tool)

- `nh os switch` - Rebuild and switch to new NixOS configuration
- `nh os test` - Test NixOS configuration without applying changes

### Legacy Commands (Deprecated)

- `just rebuild` - Stage files, rebuild system flake, and validate SOPS
- `just rebuild-trace` - Same as rebuild with `--show-trace` for debugging
- `just home` - Rebuild Home Manager configuration only
- `just build` - Stage files and run build script

### Other Commands

- `just update` - Update flake inputs (`nix flake update`)
- `just rebuild-update` - Update flakes then rebuild system

### Development & Testing

- `just ci` - Run pre-commit hooks
- `just ci-all` - Run pre-commit hooks on all files
- `just diff` - Show git diff excluding flake.lock
- `just investigate` - Analyze current system with nix-tree

### Secrets Management

- `just check-sops` - Validate SOPS activation
- `just sops-init` - Generate SOPS age key
- `just age-keys` - Generate age key for host decryption
- `just serets-update` - Update mysecrets flake input
- `just sops-edit` - Edit secrets.yaml with sops
- `just sops-updatekeys` - Re-encrypt secrets after adding new keys

### YubiKey + SOPS

- `just yubikey-setup` - Interactive setup to create age identity on YubiKey
- `just yubikey-identity [slot]` - Generate age identity from YubiKey slot
- `just yubikey-list` - List age recipients from connected YubiKeys
- `just yubikey-save-identity [slot]` - Save YubiKey identity to file for sops
- `just ssh-to-age-convert [key]` - Convert SSH public key to age format

### ISO & Installation
- `just iso-build` - Build custom NixOS installer ISO
- `just iso-write <device>` - Write ISO to USB drive (e.g., /dev/sdb)
- `just disko-format <host>` - Format disk for a host using disko
- `just disko-mount <host>` - Mount partitions after formatting
- `just disko-dry-run <host>` - Preview disko changes without applying
- `just install <host>` - Install NixOS for a host
- `just hardware-config` - Generate hardware configuration
- `just host-age-key` - Get age public key from SSH host key

## Architecture

### Directory Structure

- `flake.nix` - Main entry point defining inputs/outputs for hosts
- `hosts/` - Host-specific NixOS configurations
  - `common/core/` - Essential system configs
  - `common/optional/` - Optional system features
  - `common/optional/disko/` - Disko disk partitioning modules
  - `dellicious/` - Dell XPS 15 laptop config
  - `virt-nix/` - Virtual machine config
  - `iso/` - Custom installer ISO configuration
- `home/` - Home Manager configurations
  - `features/` - Modular feature sets (cli, desktop, development, media)
  - `klowdo/` - User-specific configs
- `modules/` - Custom NixOS and Home Manager modules
- `overlays/` - Package overlays and modifications
- `pkgs/` - Custom package definitions
- `lib/` - Custom library functions and wallpapers
- `scripts/` - Management and build scripts

### Key Technologies

- **NixOS 25.11** stable with unstable overlay
- **Home Manager** for user environment
- **Hyprland** Wayland compositor with HyprPanel
- **SOPS-nix** for secrets management (with YubiKey support via age-plugin-yubikey)
- **Disko** for declarative disk partitioning
- **Stylix + Catppuccin** theming
- **Custom Neovim** (kixvim)

### Host Configurations

- `dellicious` - Production Dell XPS 15 with Intel CPU, disabled Nvidia, Hyprland
- `virt-nix` - Testing virtual machine
- `iso` - Custom installer ISO with disko, YubiKey support, and installation tools

### Feature System

Home Manager uses feature flags in `home/features/`:

- `cli/` - Terminal tools (kitty, zsh, tmux, fzf, yazi)
- `desktop/` - Wayland/Hyprland desktop environment
- `development/` - Programming tools (.NET, Rider, LibreOffice)
- `media/` - Spotify (Spicetify), Zathura
- `communication/` - Discord, Zoom

## Development Workflow

1. **Making Changes**: Edit configurations in appropriate modules
2. **Testing**: Use `nh os test` to test configuration without applying changes
3. **Deploying**: Use `nh os switch` to apply and switch to new configuration
4. **Updates**: Use `just update` to update flake inputs
5. **CI**: Run `just ci` before committing changes

## Important Notes

- Always stage changes with `git add .` before rebuilding
- Uses **NH (Nix Helper)** as the primary build tool for improved UX and performance
- SOPS validation runs automatically after rebuilds
- The configuration uses impure evaluation for Home Manager
- Custom packages are defined in `pkgs/` with overlays in `overlays/`
- Secrets are managed via SOPS with age encryption (supports YubiKey via age-plugin-yubikey)
- Pre-commit hooks enforce code quality (nixpkgs formatting, shellcheck)
- Always commit new features

## YubiKey Setup for SOPS

To use a YubiKey for hardware-backed secret encryption:

1. **Generate YubiKey identity**: `just yubikey-setup` (interactive)
2. **Save identity file**: `just yubikey-save-identity`
3. **Add public key to .sops.yaml**: Copy the age1yubikey1... key
4. **Re-encrypt secrets**: `just sops-updatekeys`

The YubiKey provides hardware-backed encryption keys. Host keys (derived from SSH host keys) are used for decryption during system activation, while the YubiKey can be used for encrypting new secrets.
