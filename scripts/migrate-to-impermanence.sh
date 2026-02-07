#!/usr/bin/env bash
# migrate-to-impermanence.sh
#
# This script prepares an existing ext4 NixOS installation for impermanence.
# It must be run from a NixOS live USB after building the new configuration.
#
# What this script does:
# 1. Mounts the existing ext4 root partition
# 2. Reorganizes the filesystem so all data is under a /persist subdirectory
# 3. Creates the directory structure expected by the impermanence configuration
#
# Usage:
#   1. Build the new NixOS configuration with impermanence enabled
#   2. Boot from a NixOS live USB
#   3. Run this script: sudo bash migrate-to-impermanence.sh
#   4. Reboot into the new configuration

set -euo pipefail

# ── Configuration ──
DISK_UUID="b8e67ffd-5876-4c08-9000-77ac86957e54"
MOUNT_POINT="/mnt"
PERSIST_DIR="${MOUNT_POINT}/persist"
USERNAME="klowdo"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Pre-flight checks ──
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root"
    exit 1
fi

DISK_DEVICE="/dev/disk/by-uuid/${DISK_UUID}"
if [[ ! -e "${DISK_DEVICE}" ]]; then
    error "Disk with UUID ${DISK_UUID} not found"
    error "Available disks:"
    lsblk -f
    exit 1
fi

echo "============================================"
echo "  NixOS Impermanence Migration Script"
echo "============================================"
echo ""
echo "This will reorganize your ext4 root partition"
echo "so it can be used as /persist with tmpfs root."
echo ""
echo "Disk: ${DISK_DEVICE}"
echo "Mount: ${MOUNT_POINT}"
echo ""
echo "WARNING: This is a destructive operation."
echo "Make sure you have backups!"
echo ""
read -rp "Continue? (yes/no): " CONFIRM
if [[ "${CONFIRM}" != "yes" ]]; then
    info "Aborted."
    exit 0
fi

# ── Step 1: Mount the partition ──
info "Mounting ${DISK_DEVICE} at ${MOUNT_POINT}..."
mkdir -p "${MOUNT_POINT}"
mount "${DISK_DEVICE}" "${MOUNT_POINT}"

# ── Step 2: Verify this looks like a NixOS root ──
if [[ ! -d "${MOUNT_POINT}/nix" ]]; then
    error "${MOUNT_POINT}/nix not found - this doesn't look like a NixOS root"
    umount "${MOUNT_POINT}"
    exit 1
fi

if [[ -d "${PERSIST_DIR}/nix" ]]; then
    error "${PERSIST_DIR}/nix already exists - migration may have already been done"
    umount "${MOUNT_POINT}"
    exit 1
fi

# ── Step 3: Create persist directory and move everything into it ──
info "Creating ${PERSIST_DIR}..."
mkdir -p "${PERSIST_DIR}"

info "Moving all contents into ${PERSIST_DIR}..."
for item in "${MOUNT_POINT}"/*; do
    basename=$(basename "${item}")
    if [[ "${basename}" == "persist" ]]; then
        continue
    fi
    info "  Moving ${basename}..."
    mv "${item}" "${PERSIST_DIR}/"
done

# Move hidden files too
for item in "${MOUNT_POINT}"/.*; do
    basename=$(basename "${item}")
    case "${basename}" in
        .|..|persist) continue ;;
    esac
    info "  Moving ${basename}..."
    mv "${item}" "${PERSIST_DIR}/"
done

# ── Step 4: Verify critical paths ──
info "Verifying critical paths..."

CRITICAL_PATHS=(
    "${PERSIST_DIR}/nix"
    "${PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key"
    "${PERSIST_DIR}/etc/machine-id"
    "${PERSIST_DIR}/var/lib/nixos"
)

OPTIONAL_PATHS=(
    "${PERSIST_DIR}/var/lib/sops-nix/age/key.txt"
    "${PERSIST_DIR}/var/lib/systemd"
    "${PERSIST_DIR}/var/lib/tailscale"
    "${PERSIST_DIR}/var/lib/NetworkManager"
    "${PERSIST_DIR}/etc/NetworkManager/system-connections"
    "${PERSIST_DIR}/home/${USERNAME}/.ssh"
    "${PERSIST_DIR}/home/${USERNAME}/.gnupg"
    "${PERSIST_DIR}/home/${USERNAME}/.config/sops/age"
    "${PERSIST_DIR}/home/${USERNAME}/.dotfiles"
    "${PERSIST_DIR}/home/${USERNAME}/Documents"
)

ALL_GOOD=true
for path in "${CRITICAL_PATHS[@]}"; do
    if [[ -e "${path}" ]]; then
        info "  ✓ ${path}"
    else
        error "  ✗ ${path} - MISSING (CRITICAL)"
        ALL_GOOD=false
    fi
done

echo ""
info "Checking optional paths..."
for path in "${OPTIONAL_PATHS[@]}"; do
    if [[ -e "${path}" ]]; then
        info "  ✓ ${path}"
    else
        warn "  ○ ${path} - not found (will be created on first use)"
    fi
done

echo ""
if [[ "${ALL_GOOD}" == "true" ]]; then
    info "All critical paths verified successfully!"
else
    error "Some critical paths are missing. The system may not boot correctly."
    error "Consider aborting and investigating."
    read -rp "Continue anyway? (yes/no): " CONFIRM2
    if [[ "${CONFIRM2}" != "yes" ]]; then
        info "Aborted. Reverting changes..."
        # Revert: move everything back
        for item in "${PERSIST_DIR}"/*; do
            mv "${item}" "${MOUNT_POINT}/"
        done
        for item in "${PERSIST_DIR}"/.*; do
            basename=$(basename "${item}")
            case "${basename}" in
                .|..) continue ;;
            esac
            mv "${item}" "${MOUNT_POINT}/"
        done
        rmdir "${PERSIST_DIR}"
        umount "${MOUNT_POINT}"
        exit 1
    fi
fi

# ── Step 5: Summary ──
echo ""
echo "============================================"
echo "  Migration Complete!"
echo "============================================"
echo ""
echo "Filesystem layout:"
echo "  ${MOUNT_POINT}/persist/     -> Will be mounted at /persist"
echo "  ${MOUNT_POINT}/persist/nix/ -> Will be bind-mounted at /nix"
echo "  ${MOUNT_POINT}/persist/boot/ -> (Not used, /boot is separate EFI partition)"
echo ""
echo "Next steps:"
echo "  1. Unmount: umount ${MOUNT_POINT}"
echo "  2. Reboot into the new NixOS configuration"
echo "  3. Verify the system boots correctly"
echo "  4. Check that your data is accessible"
echo ""
echo "If the system doesn't boot:"
echo "  1. Boot from live USB again"
echo "  2. Mount the partition: mount ${DISK_DEVICE} ${MOUNT_POINT}"
echo "  3. Move everything back: mv ${PERSIST_DIR}/* ${MOUNT_POINT}/"
echo "  4. Remove persist dir: rmdir ${PERSIST_DIR}"
echo ""

umount "${MOUNT_POINT}"
info "Partition unmounted. Ready to reboot."
