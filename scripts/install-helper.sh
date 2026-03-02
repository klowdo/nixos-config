#!/usr/bin/env bash
set -euo pipefail

# NixOS Installation Helper Script
# Included in the custom ISO for easy installation

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_URL="${REPO_URL:-https://github.com/klowdo/nixos-config.git}"
REPO_BRANCH="${REPO_BRANCH:-claude/add-disko-iso-docs-9tRdP}"
WORK_DIR="${HOME}/nixos-config"

show_banner() {
	clear
	echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
	echo -e "${BLUE}║                                            ║${NC}"
	echo -e "${BLUE}║     ${GREEN}NixOS Installation Helper${BLUE}          ║${NC}"
	echo -e "${BLUE}║                                            ║${NC}"
	echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
	echo ""
}

step() {
	echo -e "\n${GREEN}==>${NC} ${YELLOW}$1${NC}"
}

error() {
	echo -e "${RED}ERROR:${NC} $1" >&2
	exit 1
}

success() {
	echo -e "${GREEN}✓${NC} $1"
}

warning() {
	echo -e "${YELLOW}⚠${NC} $1"
}

ask() {
	local prompt="$1"
	local var_name="$2"
	echo -ne "${BLUE}?${NC} ${prompt}: "
	# shellcheck disable=SC2229
	read -r "$var_name"
}

confirm() {
	local prompt="$1"
	local response
	echo -ne "${YELLOW}?${NC} ${prompt} (y/N): "
	read -r response
	[[ $response =~ ^[Yy]$ ]]
}

# Step 1: Network Setup
setup_network() {
	show_banner
	step "Network Setup"

	if ping -c 1 nixos.org &>/dev/null; then
		success "Already connected to the internet"
		return 0
	fi

	echo "Select network type:"
	echo "  1) WiFi"
	echo "  2) Ethernet (skip - should auto-connect)"
	echo "  3) Manual configuration"
	ask "Choice" choice

	# shellcheck disable=SC2154
	case "$choice" in
	1)
		nmcli device wifi list
		ask "WiFi SSID" ssid
		ask "WiFi Password" password
		# shellcheck disable=SC2154
		nmcli device wifi connect "$ssid" password "$password" || error "Failed to connect to WiFi"
		;;
	2)
		success "Ethernet should auto-connect via DHCP"
		;;
	3)
		warning "Opening network manager TUI..."
		nmtui
		;;
	*)
		error "Invalid choice"
		;;
	esac

	# Verify connection
	if ping -c 1 nixos.org &>/dev/null; then
		success "Internet connection established"
	else
		error "No internet connection. Please check your network settings."
	fi
}

# Step 2: Clone Repository
clone_repo() {
	show_banner
	step "Clone Configuration Repository"

	if [ -d "$WORK_DIR" ]; then
		warning "Directory $WORK_DIR already exists"
		if confirm "Remove and re-clone?"; then
			rm -rf "$WORK_DIR"
		else
			success "Using existing repository"
			cd "$WORK_DIR"
			git pull origin "$REPO_BRANCH" || warning "Failed to pull latest changes"
			return 0
		fi
	fi

	echo "Cloning from: $REPO_URL"
	echo "Branch: $REPO_BRANCH"

	git clone "$REPO_URL" "$WORK_DIR" || error "Failed to clone repository"
	cd "$WORK_DIR"

	if [ "$REPO_BRANCH" != "main" ]; then
		git checkout "$REPO_BRANCH" || error "Failed to checkout branch $REPO_BRANCH"
	fi

	success "Repository cloned successfully"
}

# Step 3: Select Host
select_host() {
	show_banner
	step "Select Host to Install"

	echo "Available hosts:"
	# shellcheck disable=SC2207,SC2011
	local hosts=($(ls -d hosts/*/ 2>/dev/null | xargs -n1 basename | grep -v common | grep -v iso))

	if [ ${#hosts[@]} -eq 0 ]; then
		error "No hosts found in repository"
	fi

	local i=1
	for host in "${hosts[@]}"; do
		echo "  $i) $host"
		((i++))
	done

	ask "Select host number" host_num

	# shellcheck disable=SC2154
	if [ "$host_num" -lt 1 ] || [ "$host_num" -gt "${#hosts[@]}" ]; then
		error "Invalid host selection"
	fi

	SELECTED_HOST="${hosts[$((host_num - 1))]}"
	success "Selected host: $SELECTED_HOST"
}

# Step 4: Verify Disk
verify_disk() {
	show_banner
	step "Verify Disk Configuration"

	echo "Current disks:"
	lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

	echo ""
	echo "Disk configuration for $SELECTED_HOST:"
	if [ -f "hosts/$SELECTED_HOST/disko.nix" ]; then
		grep "device = " "hosts/$SELECTED_HOST/disko.nix" || true
	else
		warning "No disko.nix found for this host"
	fi

	echo ""
	warning "⚠ WARNING: The disk will be COMPLETELY ERASED!"

	if ! confirm "Continue with disk formatting?"; then
		error "Installation cancelled by user"
	fi
}

# Step 5: Format Disk
format_disk() {
	show_banner
	step "Format Disk with Disko"

	echo "Running: just disko-format $SELECTED_HOST"
	echo ""

	if command -v just &>/dev/null; then
		just disko-format "$SELECTED_HOST" || error "Disko formatting failed"
	else
		# Fallback to direct nix command
		sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
			--mode disko --flake ".#$SELECTED_HOST" || error "Disko formatting failed"
	fi

	success "Disk formatted successfully"

	echo ""
	echo "Mounted filesystems:"
	mount | grep /mnt
}

# Step 6: Install NixOS
install_nixos() {
	show_banner
	step "Install NixOS"

	echo "Installing NixOS for host: $SELECTED_HOST"
	echo ""

	if grep -q "enableEncryption = true" "hosts/$SELECTED_HOST/disko.nix" 2>/dev/null; then
		warning "This host uses LUKS encryption"
		echo "You will be prompted to set a LUKS password"
		echo "Choose a strong password - this is your emergency fallback!"
		echo ""
		confirm "Ready to proceed?" || error "Installation cancelled"
	fi

	sudo nixos-install --flake ".#$SELECTED_HOST" || error "NixOS installation failed"

	success "NixOS installed successfully!"
}

# Step 7: Post-Install Instructions
show_post_install() {
	show_banner
	step "Installation Complete!"

	echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
	echo -e "${GREEN}║                                            ║${NC}"
	echo -e "${GREEN}║   NixOS installation completed! 🎉         ║${NC}"
	echo -e "${GREEN}║                                            ║${NC}"
	echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
	echo ""

	echo -e "${YELLOW}Next steps after reboot:${NC}"
	echo ""

	# Check if TPM is enabled
	if grep -q "enableTpm2 = true" "hosts/$SELECTED_HOST/disko.nix" 2>/dev/null; then
		echo "1. ${BLUE}Enroll TPM for auto-unlock:${NC}"
		echo "   sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2"
		echo ""
	fi

	# Check if FIDO2 is enabled or suggest it
	if grep -q "enableEncryption = true" "hosts/$SELECTED_HOST/disko.nix" 2>/dev/null; then
		echo "2. ${BLUE}(Optional) Enroll YubiKey:${NC}"
		echo "   sudo systemd-cryptenroll --fido2-device=auto --fido2-with-client-pin=yes /dev/nvme0n1p2"
		echo ""
	fi

	echo "3. ${BLUE}Verify unlock methods:${NC}"
	echo "   sudo systemd-cryptenroll /dev/nvme0n1p2"
	echo ""

	echo "4. ${BLUE}Update system:${NC}"
	echo "   nh os switch"
	echo ""

	if confirm "Reboot now?"; then
		reboot
	else
		echo ""
		echo "When ready, reboot with: ${BLUE}reboot${NC}"
	fi
}

# Main Menu
main_menu() {
	show_banner

	echo "Installation Steps:"
	echo "  1) Setup network"
	echo "  2) Clone repository"
	echo "  3) Select host"
	echo "  4) Verify disk"
	echo "  5) Format disk (DESTRUCTIVE!)"
	echo "  6) Install NixOS"
	echo "  7) Complete & reboot"
	echo ""
	echo "  a) Auto: Run all steps"
	echo "  q) Quit"
	echo ""

	ask "Select step" choice

	case "$choice" in
	1) setup_network && confirm "Continue?" && main_menu ;;
	2) clone_repo && confirm "Continue?" && main_menu ;;
	3) select_host && confirm "Continue?" && main_menu ;;
	4) verify_disk && confirm "Continue?" && main_menu ;;
	5) format_disk && confirm "Continue?" && main_menu ;;
	6) install_nixos && confirm "Continue?" && main_menu ;;
	7) show_post_install ;;
	a) auto_install ;;
	q) exit 0 ;;
	*) error "Invalid choice" ;;
	esac
}

# Auto installation
auto_install() {
	setup_network
	clone_repo
	select_host
	verify_disk
	format_disk
	install_nixos
	show_post_install
}

# Entry point
main() {
	if [ "$EUID" -eq 0 ]; then
		error "Please run as regular user (not root)"
	fi

	# Enable flakes if not already enabled
	if ! nix show-config 2>/dev/null | grep -q "experimental-features.*flakes"; then
		step "Enabling flakes"
		mkdir -p ~/.config/nix
		echo "experimental-features = nix-command flakes" >>~/.config/nix/nix.conf
		success "Flakes enabled"
	fi

	main_menu
}

main
