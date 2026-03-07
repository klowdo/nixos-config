# NixOS Installation Guide

This guide covers two installation methods:
1. Using the **custom ISO** built from this flake (recommended)
2. Using a **generic NixOS ISO** from nixos.org

Both methods use **disko** for declarative disk partitioning.

---

## Prerequisites

- A USB drive (4GB+ recommended)
- Target machine with UEFI boot support
- Network connection (wired recommended for easier setup)
- (Optional) YubiKey for secrets decryption

---

## Method 1: Custom ISO Installation (Recommended)

### Step 1: Build the ISO

```bash
# Build the custom installer ISO
nix build .#nixosConfigurations.iso.config.system.build.isoImage

# The ISO will be at: result/iso/nixos-klowdo-installer.iso
```

Or use the justfile command:
```bash
just iso-build
```

### Step 2: Write ISO to USB

```bash
# Find your USB device (e.g., /dev/sdb)
lsblk

# Write the ISO (replace /dev/sdX with your USB device)
sudo dd if=result/iso/nixos-klowdo-installer.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Or use a tool like Ventoy, balenaEtcher, or Rufus.

### Step 3: Boot from USB

1. Insert USB into target machine
2. Enter BIOS/UEFI settings (usually F2, F12, Del, or Esc during boot)
3. Disable Secure Boot (if enabled)
4. Boot from USB drive

### Step 4: Connect to Network

The ISO has NetworkManager enabled:

```bash
# For WiFi
nmcli device wifi list
nmcli device wifi connect "SSID" password "password"

# For Ethernet, it should auto-connect via DHCP
```

### Step 5: Clone the Configuration

```bash
# Clone the nixos-config repository
git clone https://github.com/klowdo/nixos-config.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

### Step 6: Partition Disks with Disko

First, identify your target disk:
```bash
lsblk
# Look for your NVMe or SATA drive (e.g., /dev/nvme0n1 or /dev/sda)
```

#### Option A: Create a new host with disko

1. Create a new host directory:
```bash
mkdir -p hosts/myhost
```

2. Create the host configuration (`hosts/myhost/default.nix`):
```nix
{
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Hardware
    inputs.hardware.nixosModules.common-cpu-intel  # or common-cpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    ./hardware-configuration.nix

    # Disko disk configuration
    ../common/optional/disko/uefi-btrfs.nix  # or uefi-ext4.nix

    # Common configs
    ../common/core
    ../common/users
    ../common/optional/audio.nix
    ../common/optional/bluetooth.nix
    # ... add more as needed
  ];

  # Enable disko with your disk device
  disko-btrfs = {
    enable = true;
    device = "/dev/nvme0n1";  # Change to your disk!
    swapSize = "8G";
    enableEncryption = false;  # Set to true for LUKS
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "myhost";

  system.stateVersion = "25.11";
}
```

3. Generate hardware configuration:
```bash
nixos-generate-config --root /mnt --show-hardware-config > hosts/myhost/hardware-configuration.nix
```

4. Add the host to `flake.nix`:
```nix
nixosConfigurations = {
  # ... existing hosts ...

  myhost = nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs outputs;};
    modules = [
      ./hosts/myhost
    ];
  };
};
```

#### Option B: Use disko directly (without module)

For one-time partitioning, you can use disko directly:

```bash
# Create a disko config file
cat > /tmp/disk-config.nix << 'EOF'
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";  # Change this!
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
EOF

# Run disko to partition and mount
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disk-config.nix
```

### Step 7: Setup SOPS for New Host (IMPORTANT!)

**This step is required because user passwords are SOPS-encrypted.**

The new host needs an age key derived from its SSH host key before installation.

```bash
# 1. Generate SSH host keys for the new system
sudo mkdir -p /mnt/etc/ssh
sudo ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""

# 2. Get the age public key from the new host's SSH key
cat /mnt/etc/ssh/ssh_host_ed25519_key.pub | nix-shell -p ssh-to-age --run 'ssh-to-age'
# Output: age1xxxxxxxxx... (copy this!)

# 3. Add the new host's age key to .sops.yaml
# Edit .sops.yaml and add the new key under the hosts section:
#   - &myhost age1xxxxxxxxx...
# Then add it to the creation_rules keys list

# 4. Re-encrypt secrets with the new host's key
nix-shell -p sops --run "sops updatekeys secrets.yaml"

# 5. Commit and push the updated .sops.yaml (from another machine or later)
```

**Alternative: Temporarily use a password instead of SOPS**

If you want to skip SOPS setup during initial install, temporarily edit
`hosts/common/users/klowdo.nix` and uncomment the password line:

```nix
users.users.klowdo = {
  # hashedPasswordFile = config.sops.secrets."passwords/klowdo".path;
  initialPassword = "changeme";  # Temporary - change after first boot!
  ...
};
```

Then after first boot, set up SOPS and switch back to the SOPS-managed password.

### Step 8: Install NixOS

```bash
# If using disko module (disks are already mounted at /mnt)
sudo nixos-install --flake /mnt/etc/nixos#myhost --no-root-passwd

# Set root password when prompted (or skip if using sops)
```

### Step 9: Reboot

```bash
reboot
```

---

## Method 2: Generic NixOS ISO Installation

### Step 1: Download NixOS ISO

Download the minimal ISO from https://nixos.org/download/

### Step 2: Boot from USB

Follow the same process as Method 1, Steps 2-4.

### Step 3: Enable Flakes and Install Git

```bash
# Enable flakes temporarily
export NIX_CONFIG="experimental-features = nix-command flakes"

# Install git
nix-env -iA nixos.git
```

### Step 4: Partition Disks

#### Using disko (recommended)

```bash
# Run disko directly from GitHub
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disk-config.nix
```

#### Or manually

```bash
# Example for UEFI with ext4
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 512MB 100%

# Format
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2

# Mount
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### Step 5: Clone and Install

```bash
# Clone config
git clone https://github.com/klowdo/nixos-config.git /mnt/etc/nixos
cd /mnt/etc/nixos

# Generate hardware config for new host
nixos-generate-config --root /mnt --show-hardware-config > hosts/myhost/hardware-configuration.nix

# Install (after setting up host in flake.nix)
sudo nixos-install --flake /mnt/etc/nixos#myhost
```

---

## Post-Installation Setup

### 1. First Boot

After rebooting, log in as root and:

```bash
# Set user password
passwd klowdo

# Or if using sops, the password is managed automatically
```

### 2. Clone Config to Home (if not done)

```bash
git clone https://github.com/klowdo/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 3. Setup SOPS (if using secrets)

```bash
# Generate age key for the new host
just age-keys

# Get the host's age public key (from SSH host key)
sudo cat /etc/ssh/ssh_host_ed25519_key.pub | nix-shell -p ssh-to-age --run 'ssh-to-age'

# Add the public key to .sops.yaml and re-encrypt
just sops-updatekeys
```

### 4. Enroll TPM2/FIDO2 for Disk Encryption (If Using LUKS)

If you enabled `enableEncryption` with TPM2 or FIDO2, enroll devices after installation.

**Enroll TPM2:**
```bash
# Find your encrypted partition (usually the root partition)
lsblk
# e.g., /dev/nvme0n1p2 for the root partition

# Enroll TPM2 (you'll be prompted for your LUKS password)
sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
```

**Enroll YubiKey (FIDO2):**
```bash
# Insert your YubiKey first
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p2

# For YubiKey with PIN requirement (more secure):
sudo systemd-cryptenroll --fido2-device=auto --fido2-with-client-pin=yes /dev/nvme0n1p2
```

**Verify enrolled methods:**
```bash
sudo systemd-cryptenroll /dev/nvme0n1p2
```

**Remove a method (if needed):**
```bash
# List slots
sudo cryptsetup luksDump /dev/nvme0n1p2

# Remove by slot number
sudo systemd-cryptenroll --wipe-slot=SLOT_NUMBER /dev/nvme0n1p2
```

### 5. YubiKey Setup for SOPS (Optional)

If using YubiKey for secrets encryption (separate from disk encryption):

```bash
just yubikey-setup
just yubikey-save-identity
```

### 6. Rebuild System

```bash
nh os switch
```

---

## Disko Configuration Options

### UEFI + Btrfs (with subvolumes)

```nix
disko-btrfs = {
  enable = true;
  device = "/dev/nvme0n1";
  swapSize = "8G";
  enableEncryption = true;  # Optional LUKS
  enableTpm2 = true;        # TPM2 auto-unlock (requires enableEncryption)
  enableFido2 = true;       # YubiKey unlock (requires enableEncryption)
  enablePersist = false;    # Add /persist subvolume for impermanence
};
```

Subvolumes created:
- `/root` -> `/`
- `/home` -> `/home`
- `/nix` -> `/nix`
- `/swap` -> `/.swapvol` (swapfile)
- `/persist` -> `/persist` (if `enablePersist = true`, for use with [impermanence](https://github.com/nix-community/impermanence))

### UEFI + Ext4 (simple)

```nix
disko-ext4 = {
  enable = true;
  device = "/dev/nvme0n1";
  swapSize = "8G";  # Set to "0" to disable
  enableEncryption = false;
  enableTpm2 = false;
  enableFido2 = false;
};
```

### Encryption Options

| Option | Default | Description |
|--------|---------|-------------|
| `enableEncryption` | `false` | Enable LUKS encryption for root partition |
| `enableTpm2` | `false` | TPM2 auto-unlock with password fallback |
| `enableFido2` | `false` | FIDO2/YubiKey unlock with password fallback |
| `enableHibernation` | `false` | Enable hibernation (set swapSize >= RAM) |
| `hibernationResumeOffset` | `null` | (btrfs only) Required offset for swapfile hibernation |

**Unlock priority at boot:**
1. TPM2 tries to auto-unlock (if enabled)
2. FIDO2/YubiKey prompted (if enabled and TPM fails)
3. Password prompt as final fallback

You can enable both TPM2 and FIDO2 simultaneously for redundancy.

### Hibernation Setup

**For ext4:** Just set `enableHibernation = true` and ensure `swapSize` >= RAM.

**For btrfs:** Requires an extra step after first boot:
```bash
# Get the swapfile offset
sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile

# Add the returned value to your config:
# hibernationResumeOffset = "XXXXX";

# Rebuild
nh os switch
```

**Note:** With TPM2 + hibernation, you may need to re-enroll after hibernation if PCR values change. Consider using `--tpm2-pcrs=0,7` during enrollment to avoid volatile PCRs.

---

## Secure Boot Setup (Optional)

This configuration supports UEFI Secure Boot via [lanzaboote](https://github.com/nix-community/lanzaboote). Secure Boot protects against bootkits and unauthorized boot modifications.

### Prerequisites

- UEFI firmware with Secure Boot support
- BIOS/UEFI password set (recommended)
- Disk encryption enabled (recommended)

### Step 1: Enable the Module

Add the secure-boot module to your host configuration:

```nix
{
  imports = [
    ../common/optional/secure-boot.nix
    # ... other imports
  ];
}
```

### Step 2: Create Signing Keys

```bash
# Create the Secure Boot signing keys
sudo sbctl create-keys
```

### Step 3: Rebuild NixOS

```bash
# Rebuild with lanzaboote (still boots without Secure Boot enabled)
nh os switch
```

### Step 4: Verify Signing

```bash
# Check that all boot files are signed
sudo sbctl verify

# You should see all files marked as "Signed"
```

### Step 5: Enroll Keys in Firmware

1. Reboot and enter BIOS/UEFI settings
2. Find Secure Boot settings and put it in **Setup Mode** (clears existing keys)
3. Boot back into NixOS

```bash
# Enroll your keys (includes Microsoft keys for compatibility with hardware)
sudo sbctl enroll-keys --microsoft
```

### Step 6: Enable Secure Boot

1. Reboot and enter BIOS/UEFI settings
2. Enable Secure Boot
3. Boot NixOS

### Verification

```bash
# Check Secure Boot status
bootctl status

# Should show: Secure Boot: enabled
```

### Optional: TPM + Secure Boot for LUKS

For maximum security, bind LUKS decryption to both TPM and Secure Boot state:

```bash
# Enroll TPM with PCRs that include Secure Boot state
sudo systemd-cryptenroll --tpm2-device=auto \
  --tpm2-pcrs=0+2+7+12+13+14+15 \
  --wipe-slot=tpm2 \
  /dev/nvme0n1p2
```

PCR meanings:
- **PCR 0+2**: UEFI firmware integrity
- **PCR 7**: Secure Boot state (keys enrolled, SB enabled)
- **PCR 12+13+14**: Boot loader integrity
- **PCR 15**: No LUKS partition opened yet

This ensures the disk only auto-unlocks when:
- Secure Boot is enabled with your keys
- Boot files haven't been tampered with
- Firmware hasn't been modified

---

## Troubleshooting

### Boot Issues

1. **Secure Boot**: Disable in BIOS for initial install, or use lanzaboote (see Secure Boot Setup)
2. **Wrong boot mode**: Ensure UEFI mode, not Legacy/CSM
3. **Missing bootloader**: Re-run `bootctl install` from live USB (or `sbctl sign` if using Secure Boot)

### Network Issues

```bash
# Check network status
ip addr
nmcli device status

# Restart NetworkManager
systemctl restart NetworkManager
```

### Disko Issues

```bash
# Check disk state
lsblk -f

# Unmount everything and retry
umount -R /mnt
```

### SOPS Issues

```bash
# Verify age key exists
cat ~/.config/sops/age/keys.txt

# Test decryption
sops -d secrets.yaml
```

### Secure Boot Issues

```bash
# Check Secure Boot status
bootctl status

# Check if files are signed
sudo sbctl verify

# Re-sign all boot files after kernel update
sudo sbctl sign-all

# If keys weren't enrolled properly, re-enroll
sudo sbctl enroll-keys --microsoft
```

If boot fails after enabling Secure Boot:
1. Enter BIOS and disable Secure Boot temporarily
2. Boot NixOS and run `sudo sbctl verify` to check signatures
3. Re-run `nh os switch` to ensure everything is signed
4. Re-enable Secure Boot

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `just iso-build` | Build custom installer ISO |
| `just disko-format HOST` | Format disk for HOST using disko |
| `just install HOST` | Install NixOS for HOST |
| `nh os switch` | Rebuild and switch configuration |
| `just check-sops` | Verify SOPS is working |
