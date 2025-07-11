# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a sophisticated NixOS dotfiles configuration using Nix flakes that manages both system-level (NixOS) and user-level (Home Manager) configurations. The repository follows a modular, feature-based architecture with two hosts: `dellicious` (Dell XPS 15) and `virt-nix` (VM).

## Common Commands

### Build & Deploy
- `just rebuild` - Stage files, rebuild system flake, and validate SOPS
- `just rebuild-trace` - Same as rebuild with `--show-trace` for debugging
- `just home` - Rebuild Home Manager configuration only
- `just build` - Stage files and run build script
- `just update` - Update flake inputs (`nix flake update`)
- `just rebuild-update` - Update flakes then rebuild system

### Development & Testing
- `just ci` - Run pre-commit hooks
- `just ci-all` - Run pre-commit hooks on all files
- `just diff` - Show git diff excluding flake.lock
- `just investigate` - Analyze current system with nix-tree
- `nh os test` - Test NixOS configuration without applying changes

### Direct Commands
- `sudo nixos-rebuild switch --flake .#<hostname>` - Direct system rebuild
- `home-manager --impure --flake . switch` - Direct Home Manager rebuild
- `nh os switch` - Alternative rebuild using NH tool

### Secrets Management
- `just check-sops` - Validate SOPS activation
- `just sops-init` - Generate SOPS age key
- `just age-keys` - Generate age key for host decryption
- `just serets-update` - Update mysecrets flake input

## Architecture

### Directory Structure
- `flake.nix` - Main entry point defining inputs/outputs for hosts
- `hosts/` - Host-specific NixOS configurations
  - `common/core/` - Essential system configs
  - `common/optional/` - Optional system features
  - `dellicious/` - Dell XPS 15 laptop config
  - `virt-nix/` - Virtual machine config
- `home/` - Home Manager configurations
  - `features/` - Modular feature sets (cli, desktop, development, media)
  - `klowdo/` - User-specific configs
- `modules/` - Custom NixOS and Home Manager modules
- `overlays/` - Package overlays and modifications
- `pkgs/` - Custom package definitions
- `lib/` - Custom library functions and wallpapers
- `scripts/` - Management and build scripts

### Key Technologies
- **NixOS 25.05** stable with unstable overlay
- **Home Manager** for user environment
- **Hyprland** Wayland compositor with HyprPanel
- **SOPS-nix** for secrets management
- **Stylix + Catppuccin** theming
- **Custom Neovim** (kixvim)

### Host Configurations
- `dellicious` - Production Dell XPS 15 with Intel CPU, disabled Nvidia, Hyprland
- `virt-nix` - Testing virtual machine

### Feature System
Home Manager uses feature flags in `home/features/`:
- `cli/` - Terminal tools (kitty, zsh, tmux, fzf, yazi)
- `desktop/` - Wayland/Hyprland desktop environment
- `development/` - Programming tools (.NET, Rider, LibreOffice)
- `media/` - Spotify (Spicetify), Zathura
- `communication/` - Discord, Zoom

## Development Workflow

1. **Making Changes**: Edit configurations in appropriate modules
2. **Testing**: Use `just rebuild` to apply and validate changes
3. **Home Manager Only**: Use `just home` for user-level changes
4. **Updates**: Use `just update` to update flake inputs
5. **Debugging**: Use `just rebuild-trace` for detailed error output
6. **CI**: Run `just ci` before committing changes

## Important Notes

- Always stage changes with `git add .` before rebuilding (handled by just commands)
- SOPS validation runs automatically after rebuilds
- The configuration uses impure evaluation for Home Manager
- Custom packages are defined in `pkgs/` with overlays in `overlays/`
- Secrets are managed via SOPS with age encryption
- Pre-commit hooks enforce code quality (nixpkgs formatting, shellcheck)