# GPG Key Management with YubiKey Smartcard Support

#################### GPG Key Generation ####################

# Generate a new GPG master key (RSA 4096, 2 year expiry)
gpg-generate:
  @echo "Generating a new GPG master key..."
  @echo "Recommended: Use RSA 4096, set 2y expiry, add signing + encryption + authentication subkeys."
  @echo ""
  gpg --full-generate-key

# Generate GPG key non-interactively (for automation)
gpg-generate-quick email="klowdo@klowdo.dev" name="Felix Svensson":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Generating GPG key for {{name}} <{{email}}>..."
  echo "You will be prompted for a passphrase."
  gpg --quick-generate-key "{{name}} <{{email}}>" rsa4096 cert 2y
  FPR=$(gpg --list-keys --with-colons "{{email}}" | awk -F: '/^fpr:/{print $10; exit}')
  echo ""
  echo "Master key fingerprint: $FPR"
  echo ""
  echo "Adding subkeys..."
  gpg --quick-add-key "$FPR" rsa4096 sign 2y
  gpg --quick-add-key "$FPR" rsa4096 encr 2y
  gpg --quick-add-key "$FPR" rsa4096 auth 2y
  echo ""
  echo "Key generation complete. Subkeys created for signing, encryption, and authentication."
  echo ""
  echo "Next steps:"
  echo "  1. Back up your master key: just gpg-backup"
  echo "  2. Move keys to YubiKey: just gpg-to-yubikey"
  echo "  3. Set your key ID in dellicious.nix: keyId = \"0x${FPR: -16}\";"

#################### Key Information ####################

# List all GPG keys
gpg-list:
  gpg --list-keys --keyid-format 0xlong

# List secret GPG keys
gpg-list-secret:
  gpg --list-secret-keys --keyid-format 0xlong

# Show GPG key fingerprints
gpg-fingerprints:
  gpg --fingerprint --fingerprint --keyid-format 0xlong

# Show YubiKey smartcard status
gpg-card-status:
  gpg --card-status

#################### YubiKey Smartcard Operations ####################

# Move GPG subkeys to YubiKey (interactive - moves signing, encryption, auth keys)
gpg-to-yubikey:
  @echo "Moving GPG subkeys to YubiKey smartcard..."
  @echo ""
  @echo "IMPORTANT: This MOVES keys to the YubiKey (they are removed from disk)."
  @echo "Make sure you have a backup first! (run: just gpg-backup)"
  @echo ""
  @echo "You will use 'keytocard' in the GPG edit interface:"
  @echo "  1. Select each subkey with 'key N'"
  @echo "  2. Run 'keytocard' to move it"
  @echo "  3. Choose the appropriate slot (1=sign, 2=encrypt, 3=auth)"
  @echo ""
  @read -p "Enter your key ID or email (e.g., klowdo@klowdo.dev): " keyid && \
    gpg --edit-key "$$keyid"

# Configure YubiKey smartcard settings (name, PIN, etc.)
gpg-card-setup:
  @echo "Entering YubiKey smartcard admin mode..."
  @echo ""
  @echo "Default PINs:"
  @echo "  User PIN:  123456"
  @echo "  Admin PIN: 12345678"
  @echo ""
  @echo "Recommended actions:"
  @echo "  admin    → Enter admin mode"
  @echo "  passwd   → Change User PIN, Admin PIN, and Reset Code"
  @echo "  name     → Set cardholder name"
  @echo "  url      → Set key URL for fetching public key"
  @echo "  forcesig → Toggle forced PIN for signing"
  @echo ""
  gpg --card-edit

# Fetch GPG public key from YubiKey URL
gpg-card-fetch:
  @echo "Fetching public key from URL stored on YubiKey..."
  gpg --card-edit fetch quit

# Reload GPG agent (useful after inserting/removing YubiKey)
gpg-reload:
  gpg-connect-agent reloadagent /bye
  @echo "GPG agent reloaded."

# Kill and restart GPG agent
gpg-restart:
  gpgconf --kill gpg-agent
  gpgconf --launch gpg-agent
  @echo "GPG agent restarted."

#################### Key Backup & Recovery ####################

# Export GPG public key (safe to share)
gpg-export-public email="klowdo@klowdo.dev":
  #!/usr/bin/env bash
  set -euo pipefail
  outfile="$HOME/gpg-public-{{email}}.asc"
  gpg --armor --export "{{email}}" > "$outfile"
  echo "Public key exported to: $outfile"
  echo ""
  echo "Fingerprint:"
  gpg --fingerprint "{{email}}"

# Backup GPG secret keys (handle with extreme care!)
gpg-backup email="klowdo@klowdo.dev":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "WARNING: This exports your SECRET keys. Handle with extreme care!"
  read -p "Continue? (y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
  backup_dir="$HOME/gpg-backup-$(date +%Y%m%d)"
  mkdir -p "$backup_dir"
  gpg --armor --export "{{email}}" > "$backup_dir/public.asc"
  gpg --armor --export-secret-keys "{{email}}" > "$backup_dir/secret-keys.asc"
  gpg --armor --export-secret-subkeys "{{email}}" > "$backup_dir/secret-subkeys.asc"
  gpg --export-ownertrust > "$backup_dir/ownertrust.txt"
  echo ""
  echo "Backup saved to: $backup_dir/"
  echo "  public.asc         - Public key"
  echo "  secret-keys.asc    - Master + subkeys (KEEP SAFE!)"
  echo "  secret-subkeys.asc - Subkeys only"
  echo "  ownertrust.txt     - Trust database"
  echo ""
  echo "Consider also creating a paper backup: just gpg-paperkey"

# Create a paper backup of the secret key using paperkey
gpg-paperkey email="klowdo@klowdo.dev":
  #!/usr/bin/env bash
  set -euo pipefail
  outfile="$HOME/gpg-paperkey-$(date +%Y%m%d).txt"
  gpg --export-secret-key "{{email}}" | paperkey --output "$outfile"
  echo "Paper key backup saved to: $outfile"
  echo "Print this file and store it securely."

# Import a GPG key from file
gpg-import file:
  gpg --import "{{file}}"

#################### Git Signing ####################

# Show the key ID to use for git signing
gpg-signing-key email="klowdo@klowdo.dev":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "GPG signing keys for {{email}}:"
  echo ""
  gpg --list-secret-keys --keyid-format 0xlong "{{email}}" 2>/dev/null || {
    echo "No secret key found for {{email}}"
    echo "Generate one with: just gpg-generate-quick"
    exit 1
  }
  echo ""
  KEYID=$(gpg --list-secret-keys --keyid-format 0xlong "{{email}}" | grep -E "^\s+[A-F0-9]" | head -1 | tr -d ' ')
  echo "For your NixOS config (dellicious.nix), set:"
  echo "  gpg.keyId = \"$KEYID\";"

# Test GPG signing (verify it works)
gpg-test-sign:
  @echo "Testing GPG signing..."
  echo "test" | gpg --clearsign
  @echo ""
  @echo "If you see a signed message above, GPG signing is working."

# Verify a signed git commit
gpg-verify-commit commit="HEAD":
  git verify-commit {{commit}}
