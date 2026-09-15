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

#################### Multi-YubiKey Support ####################

# Move GPG subkeys to a second YubiKey (restore from backup, then keytocard)
gpg-to-second-yubikey email="klowdo@klowdo.dev":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "=== Move GPG subkeys to second YubiKey ==="
  echo ""
  echo "This workflow will:"
  echo "  1. Re-import your subkeys from backup"
  echo "  2. Move them to the currently inserted YubiKey"
  echo "  3. Refresh stubs so GPG recognizes both cards"
  echo ""
  echo "PREREQUISITES:"
  echo "  - Insert your SECOND YubiKey (not the one already set up)"
  echo "  - Have your backup directory ready (from: just gpg-backup)"
  echo ""
  read -p "Path to backup directory (e.g., ~/gpg-backup-20250101): " backup_dir
  if [[ ! -f "$backup_dir/secret-subkeys.asc" ]]; then
    echo "ERROR: $backup_dir/secret-subkeys.asc not found"
    exit 1
  fi
  echo ""
  echo "Importing subkeys from backup..."
  gpg --import "$backup_dir/secret-subkeys.asc"
  echo ""
  echo "Now move subkeys to the second YubiKey with 'keytocard'."
  echo "Use the same slot assignments as the first YubiKey:"
  echo "  key 1 → keytocard → 1 (Signature)"
  echo "  key 2 → keytocard → 2 (Encryption)"
  echo "  key 3 → keytocard → 3 (Authentication)"
  echo ""
  gpg --edit-key "{{email}}"
  echo ""
  echo "Refreshing card stubs for both YubiKeys..."
  gpg-connect-agent "scd serialno" /bye || true
  gpg --card-status > /dev/null 2>&1 || true
  echo ""
  echo "Done! Both YubiKeys should now work interchangeably."
  echo "Swap cards and run 'just gpg-card-refresh' to switch."

# Refresh GPG card stubs after swapping YubiKeys
gpg-card-refresh:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Refreshing GPG smartcard connection..."
  gpgconf --kill scdaemon
  gpg-connect-agent reloadagent /bye
  gpg-connect-agent "scd serialno" /bye
  gpg --card-status > /dev/null 2>&1
  echo "Card refreshed. Current card:"
  gpg --card-status 2>/dev/null | grep -E "^(Serial|Name)"

# List GPG smartcard stubs (shows which card serials GPG knows about)
gpg-list-card-stubs email="klowdo@klowdo.dev":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "GPG keygrips and card stubs for {{email}}:"
  echo ""
  gpg --list-secret-keys --with-keygrip "{{email}}"
  echo ""
  echo "Private key stubs (card serial references):"
  find ~/.gnupg/private-keys-v1.d/ -name "*.key" -exec grep -l "shadowed-private-key" {} \; 2>/dev/null | while read -r f; do
    keygrip=$(basename "$f" .key)
    echo "  $keygrip"
    grep -o 'OPENPGP.3 [^ )]*' "$f" 2>/dev/null | sed 's/^/    Card: /' || true
  done
