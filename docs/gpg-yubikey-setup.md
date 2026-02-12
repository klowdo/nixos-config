# GPG + YubiKey Setup Guide

This guide covers setting up GPG keys with YubiKey smartcard integration for:

- **Git commit signing** - Cryptographically sign commits and tags
- **Password store (pass)** - GPG-encrypted password management
- **YubiKey smartcard** - Hardware-backed key storage (keys never leave the device)

## Overview

```
                    +------------------+
                    |   GPG Master Key  |
                    | (offline backup) |
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
         +----+----+   +----+----+   +----+----+
         | Signing |   | Encrypt |   |  Auth   |
         | Subkey  |   | Subkey  |   | Subkey  |
         +----+----+   +----+----+   +----+----+
              |              |              |
              +--------------+--------------+
                             |
                    +--------+--------+
                    |    YubiKey      |
                    | (smartcard)     |
                    +-----------------+
                             |
              +--------------+--------------+
              |              |              |
         Git Signing    pass (GPG)    SSH Auth
                                    (optional)
```

## How It Fits Together

| Component | Technology | Purpose |
|-----------|-----------|---------|
| SOPS secrets | age + YubiKey/TPM | System/user secret decryption during NixOS activation |
| Git signing | GPG + YubiKey | Cryptographic proof of commit authorship |
| pass | GPG + YubiKey | Encrypted password storage |
| SSH auth | GPG auth subkey (optional) | SSH via GPG agent instead of ssh-agent |

SOPS uses **age encryption** (via `age-plugin-yubikey`), while git signing and pass use **GPG**. Both can live on the same YubiKey in different slots - age uses PIV slots, GPG uses the OpenPGP applet.

## Prerequisites

Ensure your NixOS config has these enabled:

```nix
# home/klowdo/dellicious.nix
features.cli = {
  gpg = {
    enable = true;
    enableGitSigning = true;
    keyId = "0xYOUR_KEY_ID";  # Set after key generation
  };
  password-store.enable = true;  # Optional, for pass
};
```

The system-level YubiKey support (`hosts/common/core/yubikey.nix`) provides `pcscd`, `gnupg.agent`, and the necessary udev rules.

## Step 1: Generate GPG Keys

### Option A: Quick generation (recommended)

```bash
just gpg-generate-quick
```

This creates a master key with signing, encryption, and authentication subkeys (RSA 4096, 2-year expiry).

### Option B: Interactive generation

```bash
just gpg-generate
```

Choose:
- Key type: RSA and RSA (option 1)
- Key size: 4096
- Expiry: 2y
- Name: Felix Svensson
- Email: klowdo@klowdo.dev

Then add subkeys manually:

```bash
gpg --edit-key klowdo@klowdo.dev
gpg> addkey   # Add signing subkey (RSA 4096, sign)
gpg> addkey   # Add authentication subkey (RSA 4096, auth)
gpg> save
```

### Verify your keys

```bash
just gpg-list-secret
```

You should see output like:

```
sec   rsa4096/0xABCD1234EFGH5678 2025-01-01 [C] [expires: 2027-01-01]
      Key fingerprint = ABCD 1234 EFGH 5678 ...
uid                   [ultimate] Felix Svensson <klowdo@klowdo.dev>
ssb   rsa4096/0x1111222233334444 2025-01-01 [S] [expires: 2027-01-01]
ssb   rsa4096/0x5555666677778888 2025-01-01 [E] [expires: 2027-01-01]
ssb   rsa4096/0x9999AAAABBBBCCCC 2025-01-01 [A] [expires: 2027-01-01]
```

- `[C]` = Certify (master key)
- `[S]` = Sign (for git commits)
- `[E]` = Encrypt (for pass)
- `[A]` = Authenticate (for SSH)

## Step 2: Back Up Your Keys

**Do this before moving keys to YubiKey!** Once moved, keys cannot be extracted.

```bash
# Full backup (master + subkeys + trust)
just gpg-backup

# Paper backup (for safe deposit box)
just gpg-paperkey
```

Store the backup securely (encrypted USB drive, safe, etc.).

## Step 3: Move Keys to YubiKey

### Configure the YubiKey first

```bash
just gpg-card-setup
```

In the card-edit interface:
1. Type `admin` to enter admin mode
2. Type `passwd` to change PINs:
   - Change User PIN (default: 123456) - used for daily operations
   - Change Admin PIN (default: 12345678) - used for key management
   - Set a Reset Code - for PIN reset if locked out
3. Type `name` to set cardholder name
4. Type `quit` to exit

### Move subkeys to YubiKey

```bash
just gpg-to-yubikey
```

In the edit-key interface:
```
gpg> key 1           # Select first subkey (signing)
gpg> keytocard
  > 1               # Signature slot
gpg> key 1           # Deselect
gpg> key 2           # Select second subkey (encryption)
gpg> keytocard
  > 2               # Encryption slot
gpg> key 2           # Deselect
gpg> key 3           # Select third subkey (authentication)
gpg> keytocard
  > 3               # Authentication slot
gpg> save
```

### Verify YubiKey has the keys

```bash
just gpg-card-status
```

You should see your subkeys listed under the signature, encryption, and authentication slots.

## Step 4: Configure NixOS

### Set your signing key ID

Find your signing key ID:

```bash
just gpg-signing-key
```

Update `home/klowdo/dellicious.nix`:

```nix
features.cli.gpg = {
  enable = true;
  enableGitSigning = true;
  keyId = "0xABCD1234EFGH5678";  # Your signing subkey ID
};
```

Rebuild:

```bash
git add .
nh os switch
```

### Verify git signing works

```bash
just gpg-test-sign

# Make a test commit
echo "test" > /tmp/test && cd /tmp && git init && git add test && git commit -m "test signed commit"
git log --show-signature -1
```

## Step 5: Set Up Password Store (Optional)

Once GPG is working with YubiKey:

1. Enable in config:
   ```nix
   features.cli.password-store.enable = true;
   ```

2. Rebuild: `nh os switch`

3. Initialize pass:
   ```bash
   pass init klowdo@klowdo.dev
   pass git init
   ```

4. Add passwords:
   ```bash
   pass insert email/gmail
   pass generate web/github 32
   ```

Pass encrypts with your GPG key. When the YubiKey is inserted, it decrypts automatically (prompting for your PIN).

## Step 6: Upload Public Key (Optional)

To let others verify your signatures:

```bash
# Export public key
just gpg-export-public

# Upload to keyserver
gpg --send-keys 0xYOUR_KEY_ID

# Or upload to GitHub:
# Settings > SSH and GPG keys > New GPG key
# Paste the contents of ~/gpg-public-klowdo@klowdo.dev.asc
```

## Daily Usage

### Git commits (automatic when YubiKey is inserted)

```bash
git commit -m "feat: add new feature"
# GPG signing happens automatically
# YubiKey will blink, enter PIN if prompted
```

### Password store

```bash
pass show email/gmail      # Decrypt (needs YubiKey + PIN)
pass generate web/new 32   # Generate (needs YubiKey + PIN)
pc email/gmail             # Copy to clipboard (alias)
```

### YubiKey removed

When YubiKey is not inserted:
- Git commits will fail to sign (you'll get an error)
- Pass decryption will fail
- To temporarily disable signing: `git commit --no-gpg-sign -m "msg"`

### Troubleshooting

```bash
# Reload GPG agent (after inserting YubiKey)
just gpg-reload

# Restart GPG agent completely
just gpg-restart

# Check smartcard connection
just gpg-card-status

# Check PC/SC daemon
systemctl status pcscd

# Debug GPG agent
cat ~/.gnupg/gpg-agent.log
```

## Relationship with SOPS + age

This GPG setup is **independent** of the SOPS/age encryption used for NixOS secrets:

| | GPG (this guide) | age (SOPS) |
|---|---|---|
| YubiKey slot | OpenPGP applet | PIV slot (via age-plugin-yubikey) |
| Used for | Git signing, pass, email | NixOS secret decryption |
| Key type | RSA/ECC | X25519 |
| Setup command | `just gpg-generate-quick` | `just yubikey-setup` |

Both can coexist on the same YubiKey. The OpenPGP and PIV applets are separate.

## Quick Reference

| Command | Description |
|---------|-------------|
| `just gpg-generate-quick` | Generate GPG key with subkeys |
| `just gpg-list-secret` | List your secret keys |
| `just gpg-card-status` | Show YubiKey smartcard status |
| `just gpg-card-setup` | Configure YubiKey PINs and metadata |
| `just gpg-to-yubikey` | Move subkeys to YubiKey |
| `just gpg-backup` | Back up all keys to files |
| `just gpg-signing-key` | Show key ID for NixOS config |
| `just gpg-reload` | Reload GPG agent |
| `just gpg-restart` | Kill and restart GPG agent |
| `just gpg-test-sign` | Verify signing works |
| `just gpg-export-public` | Export public key for sharing |
