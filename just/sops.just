# Secrets Management with SOPS, YubiKey, and TPM 2.0

# Maybe redundant, but this was used to generate the key on the system that is actually
# managing secrets.yaml. If you don't want to use existing ssh key
# Generate a sops age key at `~/.config/sops/age/keys.txt`
sops-init:
  mkdir -p ~/.config/sops/age
  nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"

# Generate an age key at `~/.age-key.txt` for the host to decrypt via home-manager
age-keys:
  nix-shell -p age --run "age-keygen -o ~/.age-key.txt"

# Check for successful sops activation.
check-sops:
  scripts/check-sops.sh

# Update the `mysecrets` flake input when changes have been made to the private nix-secrets repo
secrets-update:
  nix flake lock --update-input mysecrets

# Re-encrypt secrets.yaml after adding new keys to .sops.yaml
sops-updatekeys identity="auto":
  #!/usr/bin/env bash
  set -euo pipefail
  source scripts/sops-identity.sh "{{identity}}"
  nix-shell -p sops age age-plugin-yubikey age-plugin-tpm --run "sops updatekeys secrets.yaml"

# Edit secrets.yaml with sops (identity: default, tpm, yubikey-keychain, yubikey-home, all, auto)
sops-edit identity="auto":
  #!/usr/bin/env bash
  set -euo pipefail
  source scripts/sops-identity.sh "{{identity}}"
  nix-shell -p sops age age-plugin-yubikey age-plugin-tpm --run "sops secrets.yaml"

# Decrypt a specific key from secrets.yaml
sops-get key identity="auto":
  #!/usr/bin/env bash
  set -euo pipefail
  source scripts/sops-identity.sh "{{identity}}"
  nix-shell -p sops age age-plugin-yubikey age-plugin-tpm --run "sops -d --extract '[\"{{key}}\"]' secrets.yaml"

# Show which identity would be used (for debugging)
sops-which identity="auto":
  #!/usr/bin/env bash
  set -euo pipefail
  source scripts/sops-identity.sh "{{identity}}"
  echo "SOPS_AGE_KEY is set (content loaded from identity file)"

# Show detailed info about SOPS keys and file status
sops-info:
  #!/usr/bin/env bash
  set -uo pipefail
  SOPS_AGE_DIR="${SOPS_AGE_DIR:-$HOME/.config/sops/age}"

  echo "=== Available Identity Files ==="
  shopt -s nullglob
  found=0
  for f in "$SOPS_AGE_DIR"/*.txt; do
    name=$(basename "$f")
    pubkey=$(grep -E "^age1|public key:|Recipient:" "$f" 2>/dev/null | head -1 | sed 's/.*: //' | tr -d ' ')
    echo "  $name: ${pubkey:0:20}..."
    found=1
  done
  [[ $found -eq 0 ]] && echo "  No identity files found in $SOPS_AGE_DIR"

  echo ""
  echo "=== Keys in .sops.yaml ==="
  if [[ -f .sops.yaml ]]; then
    grep -E "^\s*- age1|^\s*- &" .sops.yaml | head -20 || echo "  No age keys found"
  else
    echo "  .sops.yaml not found"
  fi

  echo ""
  echo "=== secrets.yaml Status ==="
  if [[ -f secrets.yaml ]]; then
    nix-shell -p sops age age-plugin-yubikey age-plugin-tpm --run "sops filestatus secrets.yaml" 2>/dev/null || echo "  Could not get file status"
  else
    echo "  secrets.yaml not found"
  fi

#################### YubiKey ####################

# Generate a new age identity on YubiKey (interactive setup)
yubikey-setup:
  @echo "Setting up YubiKey for age encryption..."
  @echo "This will create a new age identity on your YubiKey."
  @echo "Make sure your YubiKey is inserted."
  @echo ""
  nix-shell -p age-plugin-yubikey --run "age-plugin-yubikey"

# Generate age identity from existing YubiKey slot (non-interactive)
yubikey-identity slot="1":
  @echo "Generating age identity from YubiKey slot {{slot}}..."
  nix-shell -p age-plugin-yubikey --run "age-plugin-yubikey --identity --slot {{slot}}"

# List all age recipients from connected YubiKeys
yubikey-list:
  @echo "Listing age recipients from connected YubiKeys..."
  nix-shell -p age-plugin-yubikey --run "age-plugin-yubikey --list"

# Save YubiKey age identity to file (name: keychain or home)
yubikey-save-identity name slot="1":
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ "{{name}}" != "keychain" && "{{name}}" != "home" ]]; then
    echo "Error: name must be 'keychain' or 'home'"
    echo "Usage: just yubikey-save-identity <keychain|home> [slot]"
    exit 1
  fi
  echo "Saving YubiKey identity from slot {{slot}} as '{{name}}'..."
  echo "Make sure your '{{name}}' YubiKey is inserted."
  mkdir -p ~/.config/sops/age
  nix-shell -p age-plugin-yubikey --run "age-plugin-yubikey --identity --slot {{slot}} > ~/.config/sops/age/yubikey-{{name}}.txt"
  echo "Identity saved to ~/.config/sops/age/yubikey-{{name}}.txt"
  echo ""
  echo "Public key (add to .sops.yaml):"
  grep -E "Recipient:|public key:" ~/.config/sops/age/yubikey-{{name}}.txt | head -1 | sed 's/.*: //'

# Convert SSH key to age format (useful for ed25519-sk keys on YubiKey)
ssh-to-age-convert key="~/.ssh/id_ed25519.pub":
  @echo "Converting SSH public key to age format..."
  nix-shell -p ssh-to-age --run "cat {{key}} | ssh-to-age"

#################### TPM 2.0 ####################

# Check if TPM 2.0 is available and working
tpm-check:
  @echo "Checking TPM 2.0 status..."
  @if [ -c /dev/tpm0 ] || [ -c /dev/tpmrm0 ]; then \
    echo "✓ TPM device found"; \
    tpm2_getcap properties-fixed 2>/dev/null | head -20 || echo "Run 'tpm2_getcap properties-fixed' for details"; \
  else \
    echo "✗ No TPM device found at /dev/tpm0 or /dev/tpmrm0"; \
    echo "  Ensure TPM is enabled in BIOS and security.tpm2.enable = true in NixOS config"; \
  fi

# Generate a new age identity sealed to TPM (use pin=false to disable PIN)
tpm-setup pin="true":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Setting up TPM 2.0 for age encryption..."
  echo "This will create a new age identity sealed to your TPM."
  if [ "{{pin}}" = "true" ]; then
    echo "PIN protection enabled - you will be prompted for a PIN."
  fi
  echo ""
  if [ "{{pin}}" = "true" ]; then
    nix-shell -p age-plugin-tpm --run "sudo age-plugin-tpm --generate --pin"
  else
    nix-shell -p age-plugin-tpm --run "sudo age-plugin-tpm --generate"
  fi

# Generate TPM identity and save to file for sops (use pin=false to disable PIN)
tpm-save-identity pin="true":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Generating TPM identity and saving to ~/.config/sops/age/tpm-identity.txt..."
  if [ "{{pin}}" = "true" ]; then
    echo "PIN protection enabled - you will be prompted for a PIN."
  fi
  mkdir -p ~/.config/sops/age
  if [ "{{pin}}" = "true" ]; then
    nix-shell -p age-plugin-tpm --run "sudo age-plugin-tpm --generate --pin > ~/.config/sops/age/tpm-identity.txt"
  else
    nix-shell -p age-plugin-tpm --run "sudo age-plugin-tpm --generate > ~/.config/sops/age/tpm-identity.txt"
  fi
  echo "Identity saved to ~/.config/sops/age/tpm-identity.txt"
  echo ""
  echo "Public key (add this to .sops.yaml):"
  grep "public key:" ~/.config/sops/age/tpm-identity.txt | cut -d: -f2 | tr -d ' ' || \
    grep "^age1tpm1" ~/.config/sops/age/tpm-identity.txt

# List TPM-sealed age identities
tpm-list:
  @echo "Listing TPM-sealed age identities..."
  nix-shell -p age-plugin-tpm --run "age-plugin-tpm --list" 2>/dev/null || echo "No TPM identities found"
