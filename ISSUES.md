# Dotfiles Issues & TODOs

## Fixed Issues

### 1. ~~Duplicate Import~~ FIXED
- **File**: `hosts/dellicious/default.nix`
- **Fix**: Removed duplicate `../common/optional/default.nix` import

### 2. ~~Undefined nixpkgs-stable Input~~ FIXED
- **File**: `flake.nix`
- **Fix**: Added `nixpkgs-stable` input pointing to nixos-25.05

### 3. ~~Networking Filename Typo~~ FIXED
- **File**: `hosts/common/optional/nerworking.nix`
- **Fix**: Renamed to `networking.nix` and moved hostname to host-specific config

### 4. ~~Duplicate Packages~~ FIXED
- **File**: `home/klowdo/home.nix`
- **Fix**: Removed duplicate `ydotool`, `wl-clipboard`, and `hyprpicker`

### 5. ~~Hardcoded pkgs in homeConfigurations~~ FIXED
- **File**: `flake.nix`
- **Fix**: Using `pkgsFor.x86_64-linux` instead of `nixpkgs.legacyPackages.x86_64-linux`

### 6. ~~Centralize allowUnfree Configuration~~ FIXED
- **Files**: Multiple locations had redundant `allowUnfree = true`
- **Fix**: Centralized to single locations:
  - NixOS: `hosts/common/core/default.nix` (canonical)
  - Home Manager: `home/common/default.nix` (required for HM's separate nixpkgs)
  - Overlays: Keep in `overlays/default.nix` (required for overlay pkgs instances)
  - Removed redundant settings from `hosts/common/default.nix` and `hosts/virt-nix/configuration.nix`

### 7. ~~SOPS Validation Disabled~~ DOCUMENTED
- **Files**: `hosts/common/core/sops.nix`, `home/common/optional/sops.nix`
- **Fix**: Added comments explaining why validation is disabled (secrets.yaml contains secrets for multiple hosts/users)

### 8. ~~Hardcoded homeDirectory in SOPS~~ FIXED
- **File**: `home/common/optional/sops.nix`
- **Fix**: Changed from hardcoded `/home/klowdo` to `config.home.homeDirectory`

## Low Priority (Remaining)

### 9. Latest Kernel Usage
- **File**: `hosts/dellicious/default.nix`
- **Issue**: `linuxPackages_latest` can be unstable
- **Fix**: Consider using stable kernel for production

### 10. Review Existing TODOs
- **Files**: Various files contain TODO comments
- **Fix**: Review and complete or remove obsolete TODOs

### 11. Remaining Hardcoded Paths
- **Files**: `hosts/common/core/nh.nix`, `home/klowdo/home.nix`, `home/features/cli/nh.nix`
- **Issue**: `/home/klowdo/.dotfiles/` hardcoded in multiple places
- **Fix**: Consider using a centralized variable or config option

## Analysis Summary

Your dotfiles setup is well-structured overall with good modular design. The main build-breaking issues and configuration redundancies have been resolved.
