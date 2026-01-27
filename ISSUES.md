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
- **Fix**: Centralized to single locations

### 7. ~~SOPS Validation Disabled~~ DOCUMENTED
- **Files**: `hosts/common/core/sops.nix`, `home/common/optional/sops.nix`
- **Fix**: Added comments explaining why validation is disabled

### 8. ~~Hardcoded homeDirectory in SOPS~~ FIXED
- **File**: `home/common/optional/sops.nix`
- **Fix**: Changed from hardcoded `/home/klowdo` to `config.home.homeDirectory`

### 9. ~~Hardcoded Paths~~ FIXED
- **Files**: Multiple files had hardcoded `/home/klowdo/.dotfiles/` and other paths
- **Fix**: Created centralized config modules with smart defaults

### 10. ~~Inconsistent Module Naming~~ FIXED
- **Files**: `hosts/common/optional/resolved.nix`, `hosts/dellicious/default.nix`
- **Fix**: Standardized on `extraServices.*` pattern, removed `modules.*` pattern

### 11. ~~lib/default.nix FIXME~~ FIXED
- **File**: `lib/default.nix`
- **Fix**: Added `ifTheyExist` helper function for conditional group membership

### 12. ~~host-config Smart Defaults~~ FIXED
- **File**: `modules/nixos/host-config.nix`
- **Fix**: Added `hostConfig.home` option with smart default based on platform (Linux/macOS)

### 13. ~~User Groups Conditional~~ FIXED
- **File**: `hosts/common/users/klowdo.nix`
- **Fix**: Using `ifTheyExist` helper to conditionally add groups that may not exist on all hosts

## Low Priority (Remaining)

### 14. Latest Kernel Usage
- **File**: `hosts/dellicious/default.nix`
- **Issue**: `linuxPackages_latest` can be unstable
- **Fix**: Consider using stable kernel for production

### 15. way-displays TODOs
- **File**: `modules/home-manager/way-displays.nix`
- **Issue**: Multiple TODOs about wayload systemd target and optional settings
- **Fix**: Review and implement as needed

## Analysis Summary

Your dotfiles setup is well-structured with good modular design. Key improvements made:
- Centralized user/host-specific configuration via custom modules with smart defaults
- Added `ifTheyExist` helper for safer group membership (inspired by Misterio77's config)
- Standardized module naming pattern (`extraServices.*`)
- Improved portability with platform-aware defaults
- Removed redundant settings and duplicate code
