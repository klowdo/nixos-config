#!/usr/bin/env bash
set -euo pipefail

PARTITION_SIZE="220G"
SWAP_SIZE="8G"
PARTITION_LABEL="NixOS-Temp"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
nc='\033[0m'

info() { echo -e "${blue}[INFO]${nc} $1"; }
warn() { echo -e "${yellow}[WARN]${nc} $1"; }
error() {
	echo -e "${red}[ERROR]${nc} $1"
	exit 1
}
success() { echo -e "${green}[OK]${nc} $1"; }

if [[ $EUID -ne 0 ]]; then
	error "This script must be run as root (use sudo)"
fi

echo -e "${blue}╔════════════════════════════════════════════════════════════╗${nc}"
echo -e "${blue}║${nc}     NixOS Dual-Boot Partition Setup (220GB btrfs)         ${blue}║${nc}"
echo -e "${blue}╚════════════════════════════════════════════════════════════╝${nc}"
echo

info "Available disks:"
echo
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop\|sr\|NAME"
echo

read -rp "Enter disk to partition (e.g., nvme0n1, sda): " DISK
DISK_PATH="/dev/${DISK}"

if [[ ! -b $DISK_PATH ]]; then
	error "Disk $DISK_PATH does not exist"
fi

echo
info "Current partitions on $DISK_PATH:"
echo
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "$DISK_PATH"
echo

info "Checking for free space..."
FREE_SPACE=$(parted "$DISK_PATH" unit GB print free 2>/dev/null | grep "Free Space" | tail -1 | awk '{print $3}' | tr -d 'GB')

if [[ -z $FREE_SPACE ]] || (($(echo "$FREE_SPACE < 220" | bc -l))); then
	warn "Not enough free space detected (${FREE_SPACE:-0}GB available, need 220GB)"
	echo
	echo "Options:"
	echo "  1. Shrink an existing partition first (use gparted or parted)"
	echo "  2. Delete an existing partition"
	echo "  3. Continue anyway (if you know there's space)"
	echo
	read -rp "Continue anyway? (y/N): " CONTINUE
	[[ $CONTINUE =~ ^[Yy]$ ]] || exit 0
fi

echo
info "Existing EFI partitions:"
lsblk -o NAME,SIZE,FSTYPE,PARTLABEL "$DISK_PATH" | grep -i "vfat\|EFI" || echo "  (none found on this disk)"
echo

read -rp "Enter existing ESP partition (e.g., nvme0n1p1, sda1): " ESP_PART
ESP_PATH="/dev/${ESP_PART}"

if [[ ! -b $ESP_PATH ]]; then
	error "ESP partition $ESP_PATH does not exist"
fi

ESP_FSTYPE=$(lsblk -no FSTYPE "$ESP_PATH")
if [[ $ESP_FSTYPE != "vfat" ]]; then
	error "ESP partition is not FAT32 (found: $ESP_FSTYPE)"
fi
success "ESP partition $ESP_PATH verified (FAT32)"

echo
echo -e "${yellow}╔════════════════════════════════════════════════════════════╗${nc}"
echo -e "${yellow}║${nc}                    SUMMARY                                 ${yellow}║${nc}"
echo -e "${yellow}╠════════════════════════════════════════════════════════════╣${nc}"
echo -e "${yellow}║${nc}  Disk:           $DISK_PATH"
echo -e "${yellow}║${nc}  ESP (existing): $ESP_PATH"
echo -e "${yellow}║${nc}  New partition:  ${PARTITION_SIZE} btrfs (label: ${PARTITION_LABEL})"
echo -e "${yellow}║${nc}  Swap:           ${SWAP_SIZE} (swapfile in btrfs)"
echo -e "${yellow}║${nc}  Subvolumes:     @root, @home, @nix, @swap"
echo -e "${yellow}╚════════════════════════════════════════════════════════════╝${nc}"
echo
echo -e "${red}WARNING: This will create a new partition on $DISK_PATH${nc}"
echo -e "${red}Make sure you have backups of important data!${nc}"
echo
read -rp "Type 'yes' to proceed: " CONFIRM
[[ $CONFIRM == "yes" ]] || {
	echo "Aborted."
	exit 0
}

info "Creating ${PARTITION_SIZE} partition in free space..."

FREE_START=$(parted -s "$DISK_PATH" unit MiB print free | grep "Free Space" | tail -1 | awk '{print $1}')
if [[ -z $FREE_START ]]; then
	error "Could not find free space on $DISK_PATH"
fi

LAST_PART_NUM=$(parted -s "$DISK_PATH" print | grep "^ [0-9]" | tail -1 | awk '{print $1}')
PART_NUM=$((LAST_PART_NUM + 1))

parted -s "$DISK_PATH" mkpart primary btrfs "${FREE_START}" "${PARTITION_SIZE}"

if [[ $DISK == nvme* ]]; then
	NIXOS_PART="${DISK_PATH}p${PART_NUM}"
else
	NIXOS_PART="${DISK_PATH}${PART_NUM}"
fi

sleep 2
partprobe "$DISK_PATH"
sleep 1

if [[ ! -b $NIXOS_PART ]]; then
	error "Failed to create partition $NIXOS_PART"
fi
success "Created partition $NIXOS_PART"

info "Formatting as btrfs with label '$PARTITION_LABEL'..."
mkfs.btrfs -f -L "$PARTITION_LABEL" "$NIXOS_PART"
success "Formatted $NIXOS_PART as btrfs (label: $PARTITION_LABEL)"

info "Creating btrfs subvolumes..."
TEMP_MNT=$(mktemp -d)
mount "$NIXOS_PART" "$TEMP_MNT"

btrfs subvolume create "$TEMP_MNT/@root"
btrfs subvolume create "$TEMP_MNT/@home"
btrfs subvolume create "$TEMP_MNT/@nix"
btrfs subvolume create "$TEMP_MNT/@swap"

umount "$TEMP_MNT"
rmdir "$TEMP_MNT"
success "Created subvolumes: @root, @home, @nix, @swap"

info "Mounting subvolumes to /mnt..."
mount -o compress=zstd,noatime,subvol=@root "$NIXOS_PART" /mnt

mkdir -p /mnt/{home,nix,boot,.swapvol}

mount -o compress=zstd,noatime,subvol=@home "$NIXOS_PART" /mnt/home
mount -o compress=zstd,noatime,subvol=@nix "$NIXOS_PART" /mnt/nix
mount -o noatime,subvol=@swap "$NIXOS_PART" /mnt/.swapvol

mount "$ESP_PATH" /mnt/boot
success "Mounted all partitions to /mnt"

info "Creating ${SWAP_SIZE} swapfile..."
btrfs filesystem mkswapfile --size "$SWAP_SIZE" /mnt/.swapvol/swapfile
swapon /mnt/.swapvol/swapfile
success "Swapfile created and activated"

echo
echo -e "${green}╔════════════════════════════════════════════════════════════╗${nc}"
echo -e "${green}║${nc}                 PARTITIONING COMPLETE                      ${green}║${nc}"
echo -e "${green}╚════════════════════════════════════════════════════════════╝${nc}"
echo
info "Current mount layout:"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "$DISK_PATH"
echo
info "Next steps:"
echo "  1. Clone your dotfiles:"
echo "     git clone https://github.com/yourusername/dotfiles /mnt/etc/nixos"
echo
echo "  2. Generate hardware config:"
echo "     nixos-generate-config --no-filesystems --root /mnt"
echo
echo "  3. Install NixOS:"
echo "     nixos-install --flake /mnt/etc/nixos#<hostname>"
echo
echo "  4. After install, reboot and enjoy NixOS alongside your other OS!"
echo
