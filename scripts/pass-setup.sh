#!/usr/bin/env bash

# Pass setup script for NixOS dotfiles
# This script helps initialize and configure the password store

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GPG_ID="klowdo@klowdo.dev"
PASS_DIR="$HOME/.password-store"

print_header() {
    echo -e "${BLUE}=== Password Store Setup ===${NC}"
    echo
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    if ! command -v pass &> /dev/null; then
        print_error "pass command not found. Please run 'just home' to install it."
        exit 1
    fi
    
    if ! command -v gpg &> /dev/null; then
        print_error "gpg command not found. Please run 'just home' to install it."
        exit 1
    fi
    
    print_info "Prerequisites satisfied"
}

generate_gpg_key() {
    print_step "Checking for GPG key..."
    
    if gpg --list-secret-keys "$GPG_ID" &> /dev/null; then
        print_info "GPG key for $GPG_ID already exists"
        return 0
    fi
    
    print_info "Generating new GPG key for $GPG_ID..."
    
    # Create GPG key generation script
    cat > /tmp/gpg-keygen-script << EOF
%echo Generating a basic OpenPGP key for password store
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Klowdo
Name-Email: $GPG_ID
Expire-Date: 2y
Passphrase: 
%commit
%echo done
EOF

    # Generate the key
    gpg --batch --generate-key /tmp/gpg-keygen-script
    rm /tmp/gpg-keygen-script
    
    print_info "GPG key generated successfully"
}

init_password_store() {
    print_step "Initializing password store..."
    
    if [[ -d "$PASS_DIR" ]]; then
        print_warning "Password store already exists at $PASS_DIR"
        return 0
    fi
    
    pass init "$GPG_ID"
    print_info "Password store initialized with GPG ID: $GPG_ID"
}

setup_git_repo() {
    print_step "Setting up git repository (optional)..."
    
    if [[ -d "$PASS_DIR/.git" ]]; then
        print_info "Git repository already exists"
        return 0
    fi
    
    echo -e "${YELLOW}Do you want to initialize a git repository for syncing? (y/N)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cd "$PASS_DIR"
        git init
        git add .
        git commit -m "Initial password store"
        
        echo -e "${YELLOW}Enter git remote URL (optional, press Enter to skip):${NC}"
        read -r remote_url
        
        if [[ -n "$remote_url" ]]; then
            git remote add origin "$remote_url"
            print_info "Git remote added: $remote_url"
            print_info "Run 'pass git push -u origin main' to push to remote"
        fi
        
        print_info "Git repository initialized"
    else
        print_info "Skipping git setup"
    fi
}

show_mobile_setup() {
    print_step "Mobile setup instructions..."
    
    echo
    print_info "To sync with your phone, you have several options:"
    echo
    echo "  1. Password Store Android App:"
    echo "     - Install 'Password Store' from F-Droid or Google Play"
    echo "     - Export your GPG key: gpg --armor --export-secret-keys $GPG_ID > private.key"
    echo "     - Import the key to your phone"
    echo "     - Clone your git repository"
    echo
    echo "  2. OpenKeychain + Password Store:"
    echo "     - Install OpenKeychain and Password Store apps"
    echo "     - Generate QR code for GPG key: gpg --armor --export-secret-keys $GPG_ID | qrencode -t utf8"
    echo "     - Scan QR code with OpenKeychain"
    echo
    echo "  3. Manual transfer:"
    echo "     - Export individual passwords as QR codes"
    echo "     - Example: pass show example.com | qrencode -t utf8"
    echo
    print_warning "Remember to securely delete exported keys after import!"
}

show_usage_examples() {
    print_step "Usage examples..."
    
    echo
    print_info "Common pass commands:"
    echo "  pass insert example.com/username    # Add new password"
    echo "  pass generate example.com/username  # Generate random password"
    echo "  pass show example.com/username      # Show password"
    echo "  pass show -c example.com/username   # Copy password to clipboard"
    echo "  pass edit example.com/username      # Edit password entry"
    echo "  pass rm example.com/username        # Remove password"
    echo "  pass ls                             # List all passwords"
    echo "  pass find example                   # Search for passwords"
    echo
    print_info "OTP/2FA support:"
    echo "  pass otp insert example.com/username  # Add OTP secret"
    echo "  pass otp example.com/username         # Generate OTP code"
    echo "  pass otp uri example.com/username     # Show OTP URI"
    echo
    print_info "Git sync (if configured):"
    echo "  pass git pull    # Pull changes from remote"
    echo "  pass git push    # Push changes to remote"
    echo
    print_info "Shell aliases available:"
    echo "  p        # pass"
    echo "  pg       # pass generate"
    echo "  pe       # pass edit"
    echo "  pi       # pass insert"
    echo "  pc       # pass show -c (copy to clipboard)"
}

main() {
    print_header
    
    check_prerequisites
    generate_gpg_key
    init_password_store
    setup_git_repo
    show_mobile_setup
    show_usage_examples
    
    echo
    print_info "Password store setup complete!"
    print_info "GPG Key ID: $GPG_ID"
    print_info "Store Location: $PASS_DIR"
    echo
    print_info "Next steps:"
    echo "  1. Add your first password: pass insert example.com/username"
    echo "  2. Set up mobile app (see instructions above)"
    echo "  3. Configure git remote for syncing (optional)"
    echo
}

main "$@"