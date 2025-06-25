# Dotfiles Issues & TODOs

## High Priority (Fix First)

### 1. Duplicate Import
- **File**: `hosts/dellicious/default.nix:42-43`
- **Issue**: `../common/optional/default.nix` imported twice
- **Fix**: Remove one of the duplicate lines

### 2. Undefined nixpkgs-stable Input
- **File**: `overlays/default.nix:65`
- **Issue**: References `inputs.nixpkgs-stable` but not defined in `flake.nix`
- **Fix**: Either add `nixpkgs-stable` input to flake.nix or remove stable-packages overlay

## Medium Priority

### 3. Centralize allowUnfree Configuration
- **Files**: Multiple files have scattered `allowUnfree = true`
- **Issue**: Inconsistent configuration management
- **Fix**: Centralize in common configuration

### 4. SOPS Validation Disabled
- **File**: `hosts/common/core/sops.nix:7`
- **Issue**: `validateSopsFiles = false` bypasses security checks
- **Fix**: Enable validation or document why it's disabled

## Low Priority

### 5. Networking Filename Typo
- **File**: `hosts/common/optional/nerworking.nix`
- **Fix**: Rename to `networking.nix`

### 6. Latest Kernel Usage
- **File**: `hosts/dellicious/default.nix:69`
- **Issue**: `linuxPackages_latest` can be unstable
- **Fix**: Consider using stable kernel for production

### 7. Review Existing TODOs
- **Files**: Various files contain TODO comments
- **Fix**: Review and complete or remove obsolete TODOs

## Analysis Summary

Your dotfiles setup is well-structured overall with good modular design. The main concerns are build-breaking configuration issues (duplicate imports, undefined inputs) and some security/stability considerations.