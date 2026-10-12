# virt-nix - Virtual Machine Configuration

This is a test VM configuration with optional disko support for declarative disk partitioning.

## Disko Configuration

The disko configuration is available in `disko.nix` and includes:

- **UEFI boot** with 512M ESP partition
- **Btrfs filesystem** with the following subvolumes:
  - `/root` - Root filesystem (mounted at `/`)
  - `/home` - Home directories (mounted at `/home`)
  - `/nix` - Nix store (mounted at `/nix`)
  - `/swap` - Swap subvolume (4G swapfile at `/.swapvol/swapfile`)
  - `/persist` - Persistent storage for use with [impermanence](https://github.com/nix-community/impermanence) (mounted at `/persist`)
- **Device**: `/dev/vda` (standard virtio disk for VMs)
- **No encryption** (suitable for test VMs)

### Using Disko for Installation

1. **Boot from the custom ISO** (contains disko and installation tools):
   ```bash
   just iso-build
   just iso-write /dev/sdX  # Write to USB drive
   ```

2. **Format the disk** (from the ISO):
   ```bash
   just disko-format virt-nix
   ```

3. **Mount the partitions**:
   ```bash
   just disko-mount virt-nix
   ```

4. **Generate hardware configuration**:
   ```bash
   just hardware-config
   ```

5. **Install NixOS**:
   ```bash
   just install virt-nix
   ```

### Post-Installation

The disko configuration is safe to leave enabled after installation. It only defines the filesystem layout and won't reformat your disk during normal rebuilds. Disko only formats when explicitly run with `just disko-format`.

## Impermanence Setup (Optional)

The `/persist` subvolume is ready for use with impermanence but not configured by default. To enable impermanence:

1. Add impermanence to your flake inputs
2. Configure which files/directories to persist in `/persist`
3. Set up the appropriate bind mounts or symlinks

See the [impermanence documentation](https://github.com/nix-community/impermanence) for more details.

## Testing Disko Configuration

To preview what disko would do without making changes:

```bash
just disko-dry-run virt-nix
```
