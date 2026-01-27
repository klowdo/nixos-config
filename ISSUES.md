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

### 7. ~~SOPS Validation Disabled~~ DOCUMENTED
- **Files**: `hosts/common/core/sops.nix`, `home/common/optional/sops.nix`
- **Fix**: Added comments explaining why validation is disabled

### 8. ~~Hardcoded homeDirectory in SOPS~~ FIXED
- **File**: `home/common/optional/sops.nix`
- **Fix**: Changed from hardcoded `/home/klowdo` to `config.home.homeDirectory`

### 9. ~~Hardcoded Paths~~ FIXED
- **Files**: Multiple files had hardcoded `/home/klowdo/.dotfiles/` and other paths
- **Fix**: Created centralized config modules:
  - `modules/home-manager/user-config.nix` - defines `userConfig.dotfilesPath`, `userConfig.projectsPath`, `userConfig.fullName`, `userConfig.email`
  - `modules/nixos/host-config.nix` - defines `hostConfig.dotfilesPath`, `hostConfig.mainUser`
  - Updated `home/features/cli/nh.nix`, `home/features/development/languages/dotnet.nix`, `home/klowdo/dotfiles/git.nix`, `home/features/communication/email.nix` to use config options
  - Session variables `NH_FLAKE` and `PROJECT_FOLDERS` now set by userConfig module

## Low Priority (Remaining)

### 10. Latest Kernel Usage
- **File**: `hosts/dellicious/default.nix`
- **Issue**: `linuxPackages_latest` can be unstable
- **Fix**: Consider using stable kernel for production

### 11. Review Existing TODOs
- **Files**: Various files contain TODO comments
- Key TODOs to review:
  - `hosts/dellicious/default.nix:28` - "TODO: combine theses"
  - `hosts/dellicious/default.nix:77` - "TODO: fix this... use same names for modules"
  - `modules/home-manager/way-displays.nix` - Multiple TODOs about wayload target and optional settings
  - `lib/default.nix:1` - FIXME about adding lib functions

## Analysis Summary

Your dotfiles setup is well-structured with good modular design. The main improvements made:
- Centralized user/host-specific configuration via custom modules
- Removed redundant settings and duplicate code
- Improved portability by eliminating hardcoded paths
- Better documentation of disabled security settings
