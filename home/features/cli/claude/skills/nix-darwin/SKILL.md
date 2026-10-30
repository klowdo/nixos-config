---
name: nix-darwin
description: Use when configuring, troubleshooting, or reviewing macOS system settings managed by nix-darwin in this repository. Triggers on darwin-rebuild, launchd, Homebrew, macOS system packages, system activation, host platform settings, or the D9PDHCXWH6 Darwin configuration.
---

# nix-darwin Configuration

Use nix-darwin modules for macOS system-level configuration and Home Manager modules for user-level programs and dotfiles. Check the upstream manual and module options when using an option or behavior not already established in this repository:

- Manual: https://nix-darwin.github.io/nix-darwin/
- Source and release documentation: https://github.com/nix-darwin/nix-darwin/tree/nix-darwin-26.05/doc
- Option declarations: https://github.com/nix-darwin/nix-darwin/tree/nix-darwin-26.05/modules

## Repository layout

- `flake.nix` declares the `nix-darwin` input and the `darwinConfigurations.D9PDHCXWH6` output.
- `hosts/D9PDHCXWH6/default.nix` is the Darwin system module. It sets the Apple Silicon platform, system packages and services, Homebrew, and the Home Manager integration.
- `hosts/D9PDHCXWH6/` contains host-specific system modules.
- `home/klowdo/D9PDHCXWH6.nix` composes the user's Home Manager configuration and enables features from `home/features/`.
- Shared user features belong in the existing `home/features/` modules; do not put user dotfiles or per-user packages in the Darwin system module.

## Working practices

- Follow the existing flake output and module structure. Reuse an existing Home Manager feature when a change is user-level; add host-specific system configuration under `hosts/D9PDHCXWH6/`.
- Confirm module options and package attributes from the pinned nix-darwin and nixpkgs sources before relying on them. Do not assume NixOS module options or service behavior apply on macOS.
- Check the current host platform and primary user before changing system or Homebrew configuration. This host is `aarch64-darwin`, and its primary user is `FSVENS28`.
- Keep activation scripts and launchd services idempotent and specific to the intended host. Account for macOS restrictions on system extensions, permissions, and filesystem locations.
- Preserve the configured Home Manager integration and pass-through of `inputs` and `outputs` unless a change explicitly requires otherwise.

## Validation

For this host, check the configuration without applying it:

```bash
darwin-rebuild check --flake .#D9PDHCXWH6
```

Apply the configuration only when requested:

```bash
sudo darwin-rebuild switch --flake .#D9PDHCXWH6
```

For a narrow syntax check, use `nix-instantiate --parse` on changed Nix files. Run the repository's pre-commit hooks for formatting checks. Do not run a system switch as a validation step.
