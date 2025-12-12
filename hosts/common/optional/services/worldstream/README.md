# Worldstream VPN strongSwan Configuration

This directory contains two strongSwan VPN configurations for connecting to Worldstream VPN:

1. **Legacy ipsec.conf mode** (`strongSwan.nix`) - Original configuration
2. **Modern swanctl mode** (`strongSwan-swanctl.nix`) - **Recommended** migration

## Quick Start

### Using the Modern swanctl Configuration (Recommended)

1. **Create the secrets file** in swanctl format using the template:
   ```bash
   # Copy the example
   cp swanctl-secrets.conf.example /tmp/swanctl-secrets.conf

   # Edit with your actual PSK and XAuth password from the existing strong-swan.ipsec file
   # You can view the current secrets with:
   # sops path/to/your/strong-swan.ipsec.yaml
   ```

2. **Encrypt the secrets file with SOPS**:
   ```bash
   # Assuming you have SOPS configured for this host
   sops encrypt /tmp/swanctl-secrets.conf > secrets/strong-swan.swanctl-secrets.yaml
   ```

3. **Enable the swanctl configuration** in your host config:
   ```nix
   {
     # Disable the old configuration
     extraServices.strongSwan.enable = false;

     # Enable the new swanctl configuration
     extraServices.strongSwan-swanctl.enable = true;
   }
   ```

4. **Rebuild your system**:
   ```bash
   nh os switch
   ```

5. **Connect to VPN**:
   ```bash
   ws-vpn up      # Connect to VPN and set DNS
   ws-vpn status  # Check connection status
   ws-vpn down    # Disconnect from VPN
   ```

## Configuration Files

### strongSwan-swanctl.nix (New - Recommended)
- **Service**: `strongswan-swanctl.service`
- **Command tool**: `swanctl`
- **Config format**: Modern hierarchical swanctl.conf
- **Secrets**: `/etc/swanctl/swanctl-secrets.conf` (via SOPS)
- **DNS**: Automatically configured via `resolvectl` (systemd-resolved)
- **Key benefit**: Proper systemd-resolved integration, no resolvconf errors

### strongSwan.nix (Legacy)
- **Service**: `strongswan.service`
- **Command tool**: `ipsec`
- **Config format**: Legacy flat ipsec.conf
- **Secrets**: Via `services.strongswan.secrets`
- **Issue**: Cannot properly disable resolvconf DNS installation, causing errors in logs

## DNS Configuration

### Automatic DNS (swanctl - Recommended)

The swanctl configuration uses strongSwan's resolve plugin configured to work with systemd-resolved:

```nix
plugins {
  resolve {
    resolvconf = resolvectl  # Use resolvectl instead of legacy resolvconf
  }
}
```

When you connect, strongSwan automatically:
1. Receives DNS servers from the VPN server (10.10.16.10, 10.10.17.10)
2. Installs them via `resolvectl`
3. No manual DNS configuration needed!

### Manual DNS Override

The `ws-vpn` script includes optional manual DNS configuration as a fallback:

```bash
# Use automatic DNS (default for swanctl)
ws-vpn up

# Override with manual DNS
MANUAL_DNS=true ws-vpn up

# Disable manual DNS (rely on strongSwan)
MANUAL_DNS=false ws-vpn up
```

## The ws-vpn Script

The `ws-vpn` script automatically detects which strongSwan service is running and uses the appropriate commands:

- If `strongswan-swanctl.service` is active → uses `swanctl` commands + automatic DNS
- If `strongswan.service` is active → uses `ipsec` commands + manual DNS

### Commands:
```bash
ws-vpn up       # Connect to VPN (DNS auto-configured with swanctl)
ws-vpn down     # Disconnect from VPN and restore home DNS
ws-vpn rdns     # Manually reconfigure DNS (fallback/override)
ws-vpn status   # Show VPN connection status
```

## Secrets Format

### Converting from ipsec.secrets to swanctl

**ipsec.secrets format (legacy):**
```
@10 185.182.195.244 : PSK "password"
felix.svensson@nl.worldstream.com : XAUTH "SHARED_PASSWORD"
```

**swanctl-secrets.conf format (modern):**
```
secrets {
  # IKE Pre-Shared Key for first auth round
  # Converted from: @10 185.182.195.244 : PSK "password"
  ike-worldstream {
    secret = "password"          # The PSK value
    id-1 = "@10"                 # Local identity
    id-2 = "185.182.195.244"     # Remote gateway IP
  }

  # XAuth credentials for second auth round
  # Converted from: felix.svensson@nl.worldstream.com : XAUTH "SHARED_PASSWORD"
  # Note: XAuth uses 'eap' prefix in swanctl
  eap-worldstream {
    id = "felix.svensson@nl.worldstream.com"  # XAuth username
    secret = "SHARED_PASSWORD"                 # XAuth password
  }
}
```

**Key differences:**
- Section names use descriptive suffixes (`-worldstream`) instead of numbers
- PSK uses `id-1` (local) and `id-2` (remote) instead of colon-separated format
- XAuth/EAP uses `eap-` prefix instead of `XAUTH` keyword
- All secrets are in a single `secrets { }` block

See `swanctl-secrets.conf.example` for the complete template.

## Migration Path

1. **Current state**: Using legacy `strongSwan.nix` with resolvconf errors
2. **Prepare secrets**: Convert secrets to swanctl format and encrypt with SOPS
3. **Test swanctl**: Enable `strongSwan-swanctl.enable = true` (disable old config)
4. **Rebuild and test**: `nh os switch && ws-vpn up`
5. **Verify**: Check that no resolvconf errors appear in logs
6. **Cleanup**: Once confirmed working, you can optionally remove the old `strongSwan.nix`

## Troubleshooting

### Check which service is running:
```bash
systemctl status strongswan.service
systemctl status strongswan-swanctl.service
```

### View connection logs:
```bash
# For swanctl
journalctl -u strongswan-swanctl.service -f

# For legacy ipsec
journalctl -u strongswan.service -f
```

### List active connections:
```bash
# swanctl mode
swanctl --list-sas

# legacy ipsec mode
ipsec status
```

### Debug DNS issues:
```bash
# Check current DNS settings
resolvectl status

# Check DNS for specific interface
resolvectl dns wlp0s20f3

# Watch strongSwan DNS installation in logs
sudo journalctl -u strongswan-swanctl.service -f | grep -i dns

# Manually reconfigure DNS (override)
ws-vpn rdns

# Test DNS resolution
resolvectl query some-internal-server.worldstream.com
```

## Key Differences: ipsec.conf vs swanctl

| Feature | ipsec.conf (Legacy) | swanctl (Modern) |
|---------|-------------------|------------------|
| Config format | Flat, connection-based | Hierarchical |
| IKE version | `keyexchange=ikev1` | `version = 1` |
| Proposals | `ike=`, `esp=` | `proposals=`, `esp_proposals=` |
| Auth | `leftauth`, `rightauth` | `local.auth`, `remote.auth` |
| Secrets | Separate ipsec.secrets | Embedded in swanctl config |
| Multi-round auth | Numeric suffixes | Named sections (local.1, local.2) |
| DNS control | Limited | Full control via plugins |
| Virtual IP | `leftsourceip` | `vips` |

## Connection Details

- **Remote**: vpn-nldw.worldstream.net (185.182.195.244)
- **IKE**: IKEv1 Aggressive Mode (insecure but required by server)
- **Auth**: PSK + XAuth (two-round authentication)
- **Encryption**: AES-256-CBC, SHA2-256, DH Group 14 (MODP2048)
- **DNS Servers**: 10.10.16.10, 10.10.17.10 (set manually via resolvectl)

## References

- [strongSwan swanctl migration guide](https://wiki.strongswan.org/projects/strongswan/wiki/Fromipsecconf)
- [NixOS strongswan-swanctl options](https://search.nixos.org/options?query=strongswan-swanctl)
- [strongSwan swanctl.conf documentation](https://docs.strongswan.org/docs/5.9/swanctl/swanctlConf.html)
