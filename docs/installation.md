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

### Step 7: Install NixOS

```bash
# If using disko module (disks are already mounted at /mnt)
sudo nixos-install --flake /mnt/etc/nixos#myhost --no-root-passwd

# Set root password when prompted (or skip if using sops)
```

### Step 8: Reboot

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

### 4. YubiKey Setup (Optional)

If using YubiKey for secrets:

```bash
just yubikey-setup
just yubikey-save-identity
```

### 5. Rebuild System

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
};
```

Subvolumes created:
- `/root` -> `/`
- `/home` -> `/home`
- `/nix` -> `/nix`
- `/swap` -> `/.swapvol` (swapfile)

### UEFI + Ext4 (simple)

```nix
disko-ext4 = {
  enable = true;
  device = "/dev/nvme0n1";
  swapSize = "8G";  # Set to "0" to disable
  enableEncryption = false;
};
```

---

## Troubleshooting

### Boot Issues

1. **Secure Boot**: Disable in BIOS
2. **Wrong boot mode**: Ensure UEFI mode, not Legacy/CSM
3. **Missing bootloader**: Re-run `bootctl install` from live USB

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

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `just iso-build` | Build custom installer ISO |
| `just disko-format HOST` | Format disk for HOST using disko |
| `just install HOST` | Install NixOS for HOST |
| `nh os switch` | Rebuild and switch configuration |
| `just check-sops` | Verify SOPS is working |
