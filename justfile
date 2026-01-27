# Default recipe to display help information
default:
  @just --list

# List all recipes
list:
  @just --list

# Run ci using pre-commit
ci:
  pre-commit run

# Run ci for all files using pre-commit
ci-all:
  pre-commit run --all-files

# Run `git add .` and `./scripts/build.sh`
build:
  git add .
  scripts/build.sh

# Stage all files to git, rebuild the flake for the current, or specified hosts, and then valdiation sops activation via `just check-sops`.
rebuild:
  git add .
  scripts/system-flake-rebuild.sh
  just check-sops

# Same as `just rebuild` except with the `--show-trace` flag enabled.
rebuild-trace:
  git add .
  scripts/system-flake-rebuild-trace.sh
  just check-sops

# Run `nix flake update`.
update:
  nix flake update

# Run `just update` followed by `just rebuild`.
rebuild-update:
  just update
  just rebuild

# Run `git diff ':!flake.lock'`
diff:
  git diff ':!flake.lock'

#################### Home Manager ####################

# Run `home-manager --impure --flake . switch` and `just check-sops`
home:
  # HACK: This is is until the home manager bug is fixed, otherwise any adding extensions deletes all of them
  # rm $HOME/.vscode/extensions/extensions.json || true
  home-manager --impure --flake . switch
  just check-sops

# Run `just update` and `just home`
home-update:
  just update
  just home

#################### Secrets Management ####################

# TODO sops: update or relocate to nix-secrets?
# SOPS_FILE := "./hosts/common/secrets.yaml"

# TODO sops: update or relocate to nix-secrets?
# Edit the sops files using nix-shell
# sops:
#   @echo "Editing {{SOPS_FILE}}"
#   nix-shell -p sops --run "SOPS_AGE_KEY_FILE=~/.age-key.txt sops {{SOPS_FILE}}"

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
serets-update:
  nix flake lock --update-input mysecrets

#################### YubiKey + SOPS ####################

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

# Save YubiKey age identity to file for sops decryption
yubikey-save-identity slot="1":
  @echo "Saving YubiKey identity from slot {{slot}} to ~/.config/sops/age/yubikey-identity.txt..."
  mkdir -p ~/.config/sops/age
  nix-shell -p age-plugin-yubikey --run "age-plugin-yubikey --identity --slot {{slot}} > ~/.config/sops/age/yubikey-identity.txt"
  @echo "Identity saved. Add this file path to your sops.nix configuration."
  @echo "Public key (add to .sops.yaml):"
  @grep "public key:" ~/.config/sops/age/yubikey-identity.txt | cut -d: -f2 | tr -d ' '

# Convert SSH key to age format (useful for ed25519-sk keys on YubiKey)
ssh-to-age-convert key="~/.ssh/id_ed25519.pub":
  @echo "Converting SSH public key to age format..."
  nix-shell -p ssh-to-age --run "cat {{key}} | ssh-to-age"

# Re-encrypt secrets.yaml after adding new keys to .sops.yaml
sops-updatekeys:
  @echo "Updating keys for secrets.yaml based on .sops.yaml..."
  nix-shell -p sops --run "sops updatekeys secrets.yaml"

# Edit secrets.yaml with sops
sops-edit:
  @echo "Editing secrets.yaml..."
  nix-shell -p sops age age-plugin-yubikey --run "sops secrets.yaml"

#################### Password Store ####################

# Initialize password store with GPG key generation and setup
pass-setup:
  scripts/pass-setup.sh

# Generate a new GPG key for password store
pass-gpg-gen:
  gpg --full-generate-key

# Export GPG key for mobile/backup (WARNING: handle securely!)
pass-export-key:
  @echo "Exporting GPG private key for klowdo@klowdo.dev..."
  @echo "WARNING: This will export your private key. Handle with extreme care!"
  @read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
  gpg --armor --export-secret-keys klowdo@klowdo.dev > ~/.password-store-key.asc
  @echo "Key exported to ~/.password-store-key.asc"
  @echo "Import to mobile: gpg --import ~/.password-store-key.asc"
  @echo "Remember to securely delete this file when done!"

# Show GPG key fingerprint for verification
pass-key-info:
  gpg --list-secret-keys klowdo@klowdo.dev

# Backup password store to encrypted archive
pass-backup:
  @echo "Creating encrypted backup of password store..."
  tar -czf - ~/.password-store ~/.gnupg | gpg --cipher-algo AES256 --compress-algo 2 --symmetric --output ~/password-store-backup-$(date +%Y%m%d).tar.gz.gpg
  @echo "Backup created: ~/password-store-backup-$(date +%Y%m%d).tar.gz.gpg"

# great too to check current system
investigate:
  nix run github:utdemir/nix-tree
