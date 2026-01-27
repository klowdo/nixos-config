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

## Medium Priority (Remaining)

### 6. Centralize allowUnfree Configuration
- **Files**: Multiple files have scattered `allowUnfree = true`
- **Issue**: Inconsistent configuration management
- **Fix**: Centralize in common configuration

### 7. SOPS Validation Disabled
- **File**: `hosts/common/core/sops.nix:7`
- **Issue**: `validateSopsFiles = false` bypasses security checks
- **Fix**: Enable validation or document why it's disabled

## Low Priority (Remaining)

### 8. Latest Kernel Usage
- **File**: `hosts/dellicious/default.nix`
- **Issue**: `linuxPackages_latest` can be unstable
- **Fix**: Consider using stable kernel for production

### 9. Review Existing TODOs
- **Files**: Various files contain TODO comments
- **Fix**: Review and complete or remove obsolete TODOs

## Analysis Summary

Your dotfiles setup is well-structured overall with good modular design. The main build-breaking issues have been resolved in this PR.
