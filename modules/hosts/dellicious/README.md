# dellicious - Dell XPS 15 9530 Configuration

Production laptop configuration with full disk encryption, TPM2 auto-unlock, and impermanence support.

## Disko Configuration

The disko configuration is available in `disko.nix` and includes:

- **UEFI boot** with 512M ESP partition
- **LUKS encryption** with TPM2 auto-unlock
- **Btrfs filesystem** with the following subvolumes:
  - `/root` - Root filesystem (mounted at `/`)
  - `/home` - Home directories (mounted at `/home`)
  - `/nix` - Nix store (mounted at `/nix`)
  - `/swap` - Swap subvolume (32G swapfile at `/.swapvol/swapfile`)
  - `/persist` - Persistent storage for use with [impermanence](https://github.com/nix-community/impermanence) (mounted at `/persist`)
- **Device**: `/dev/nvme0n1` (NVMe SSD)
- **TPM2 auto-unlock** with password fallback for LUKS

## Security Features

- **LUKS encryption**: Full disk encryption for data protection
- **TPM2 auto-unlock**: Automatic unlock at boot (no password needed)
- **Password fallback**: If TPM fails, password prompt appears
- **Persist subvolume**: Ready for impermanence setup

## Installation

### Fresh Installation with Disko

1. **Boot from the custom ISO**:
   ```bash
   just iso-build
   just iso-write /dev/sdX
   ```

2. **Boot from USB and clone the config**:
   ```bash
   git clone <your-repo> /tmp/dotfiles
   cd /tmp/dotfiles
   ```

3. **Format and mount**:
   ```bash
   just disko-format dellicious
   ```

   You'll be prompted to set a LUKS password. **Remember this password** - it's your fallback if TPM unlock fails.

4. **Install NixOS**:
   ```bash
   sudo nixos-install --flake .#dellicious
   ```

5. **First boot - Enroll TPM2**:

   After first boot, enroll the TPM for auto-unlock:
   ```bash
   # Enroll TPM2 (you'll be prompted for your LUKS password)
   sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2

   # Verify TPM is enrolled
   sudo systemd-cryptenroll /dev/nvme0n1p2
   ```

## Hibernation (Optional)

The swap size (32G) is configured to support hibernation for systems with up to 32GB RAM.

To enable hibernation:

1. Set `enableHibernation = true` in `disko.nix` **before formatting**

2. After first boot, get the swapfile offset:
   ```bash
   sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
   ```

3. Set the offset in `disko.nix`:
   ```nix
   hibernationResumeOffset = "XXXXX";  # Use the value from above
   ```

4. Rebuild:
   ```bash
   nh os switch
   ```

**Note**: With TPM2 + hibernation, PCR values may change. Use specific PCRs during enrollment:
```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2
```

## TPM Management

### Check TPM Status
```bash
# Verify TPM is available
just tpm-check

# Check enrolled unlock methods
sudo systemd-cryptenroll /dev/nvme0n1p2
```

### Re-enroll TPM (if needed)
```bash
# Remove old TPM enrollment
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2

# Enroll TPM again
sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
```

### Add YubiKey as Additional Unlock Method
```bash
# Add FIDO2/YubiKey (in addition to TPM)
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p2
```

## Impermanence Setup (Optional)

The `/persist` subvolume is ready for use with impermanence but not configured by default.

To enable impermanence:

1. Add impermanence to your flake inputs
2. Configure which files/directories to persist in `/persist`
3. Consider using tmpfs for root to clear on boot
4. Set up the appropriate bind mounts or symlinks

See the [impermanence documentation](https://github.com/nix-community/impermanence) for more details.

## Testing Disko Configuration

To preview what disko would do without making changes:

```bash
just disko-dry-run dellicious
```

## Post-Installation

The disko configuration is safe to leave enabled after installation. It only defines the filesystem layout and won't reformat your disk during normal rebuilds. Disko only formats when explicitly run with `just disko-format`.
