# Default recipe to display help information
default:
  @just --list

import 'just/sops.just'
import 'just/home.just'
import 'just/pass.just'

# List all recipes
list:
  @just --list

# Run ci using pre-commit
ci:
  pre-commit run

# Run ci for all files using pre-commit
ci-all:
  pre-commit run --all-files

# Run `git add .` and `./scripts/build.sh`
build:
  git add .
  scripts/build.sh

# Stage all files to git, rebuild the flake for the current, or specified hosts, and then valdiation sops activation via `just check-sops`.
rebuild:
  git add .
  scripts/system-flake-rebuild.sh
  just check-sops

# Same as `just rebuild` except with the `--show-trace` flag enabled.
rebuild-trace:
  git add .
  scripts/system-flake-rebuild-trace.sh
  just check-sops

# Run `nix flake update`.
update:
  nix flake update

# Run `just update` followed by `just rebuild`.
rebuild-update:
  just update
  just rebuild

# Run `git diff ':!flake.lock'`
diff:
  git diff ':!flake.lock'

# Analyze current system with nix-tree
investigate:
  nix run github:utdemir/nix-tree

#################### ISO & Installation ####################

# Build the graphical NixOS installer ISO (default)
iso-build:
  @echo "Building graphical NixOS installer ISO..."
  nix build .#nixosConfigurations.iso.config.system.build.isoImage
  @echo "ISO built at: result/iso/nixos-klowdo-installer.iso"

# Build the minimal NixOS installer ISO (CLI only)
iso-build-minimal:
  @echo "Building minimal NixOS installer ISO..."
  nix build .#nixosConfigurations.iso-minimal.config.system.build.isoImage
  @echo "ISO built at: result/iso/nixos-klowdo-installer.iso"

# Write ISO to USB drive (requires sudo, device e.g. /dev/sdb)
iso-write device:
  @echo "WARNING: This will ERASE all data on {{device}}!"
  @read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
  sudo dd if=result/iso/nixos-klowdo-installer.iso of={{device}} bs=4M status=progress oflag=sync
  @echo "ISO written to {{device}}"

#################### Disko ####################

# Format disk for a host using disko (run from installer)
disko-format host:
  @echo "Formatting disk for {{host}} using disko..."
  @echo "WARNING: This will ERASE the target disk!"
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake .#{{host}}

# Mount partitions for a host (after formatting)
disko-mount host:
  @echo "Mounting partitions for {{host}}..."
  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode mount --flake .#{{host}}

# Show what disko would do without making changes
disko-dry-run host:
  @echo "Dry run for {{host}} disko configuration..."
  nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode dry-run --flake .#{{host}}

#################### Installation ####################

# Install NixOS for a host (run from installer with disks mounted at /mnt)
install host:
  @echo "Installing NixOS for {{host}}..."
  sudo nixos-install --flake .#{{host}} --no-root-passwd
  @echo "Installation complete! You can now reboot."

# Generate hardware configuration for current machine
hardware-config:
  @echo "Generating hardware configuration..."
  nixos-generate-config --show-hardware-config

# Get age public key from SSH host key (for .sops.yaml)
host-age-key:
  @echo "Age public key for this host:"
  sudo cat /etc/ssh/ssh_host_ed25519_key.pub | nix-shell -p ssh-to-age --run 'ssh-to-age'
