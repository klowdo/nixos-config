# Password Store recipes

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
