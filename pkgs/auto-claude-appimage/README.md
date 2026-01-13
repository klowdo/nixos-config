# Auto-Claude AppImage Package (Patched)

This package wraps the official Auto-Claude AppImage with a patch to fix immutable environment support for NixOS.

## What This Package Does

1. **Downloads** the official Auto-Claude AppImage from GitHub releases
2. **Extracts** the AppImage contents using `appimageTools`
3. **Patches** the `app.asar` file (Electron's packaged code) to add immutable environment detection
4. **Wraps** it in an FHS environment with all necessary system libraries
5. **Installs** desktop entry and icon for system integration

## The Patch

The package applies the fix from [GitHub Issue #143](https://github.com/AndyMik90/Auto-Claude/issues/143#issuecomment-3736686937) which adds code to detect immutable environments (like NixOS) and copy the backend to a writable temporary location.

The patching happens at build time by:
- Extracting `resources/app.asar` using the `asar` tool
- Finding `path-resolver.js` (the compiled TypeScript)
- Injecting the immutable environment handler using `sed`
- Repacking the modified `app.asar`

## Advantages

- ✅ **No source build required** - uses pre-built AppImage
- ✅ **Faster builds** - only extraction and patching
- ✅ **No Node 24+ requirement** - bundled runtime
- ✅ **Proven to work** - based on upstream release

## Disadvantages

- ⚠️ **Less Nix-native** - uses FHS environment
- ⚠️ **Manual updates** - need to update version and hash
- ⚠️ **Larger size** - includes full Electron runtime

## Building

```bash
nix build .#auto-claude-appimage
```

## Usage

Add to your NixOS configuration:

```nix
{
  environment.systemPackages = with pkgs; [
    auto-claude-appimage
  ];
}
```

Then run:
```bash
auto-claude
```

## Updating to New Version

1. Check [GitHub releases](https://github.com/AndyMik90/Auto-Claude/releases) for new version
2. Update `version` in `default.nix`
3. Update `hash` in `fetchurl`:
   - Set to `lib.fakeHash`
   - Run `nix build .#auto-claude-appimage`
   - Copy the correct hash from error message
4. Test the build

## Troubleshooting

### AppImage won't launch
Check that all dependencies are included in `extraPkgs`. The current list includes all standard Electron dependencies.

### Backend not found
This is the issue the patch fixes. If you still see this, the patch may not have been applied correctly. Check build logs for "Patching path-resolver.js" messages.

### Permission errors
The FHS environment should handle this, but ensure XDG directories are writable:
- `~/.cache/auto-claude`
- `~/.config/auto-claude`
- `~/.local/share/auto-claude`
