---
name: unifi-network
description: UniFi network best practices and guardrails. Use when inspecting or changing a UniFi network via the unifi-network MCP server — VLANs, firewall rules, WiFi, client management, or auditing controller config.
user-invocable: true
allowed-tools: mcp__unifi-network__*
---

# UniFi Network Best Practices

Guidance for working with the `unifi-network` MCP server. Read before making any change — all mutations use preview-then-confirm, so always show the diff and get explicit approval before applying.

## Golden rules

- **Read before write.** List the current state (clients, rules, networks) before proposing a change. Never assume topology.
- **One change at a time.** Apply, verify the controller reports success, then continue. Don't batch unrelated mutations.
- **Never lock yourself out.** Before touching firewall/management rules, confirm the change can't block the controller's own management VLAN or your admin client.
- **Prefer additive over destructive.** Disable a rule instead of deleting it when auditing; you can re-enable without losing config.

## VLAN & segmentation

- Separate trust zones onto their own VLANs: management, trusted LAN, IoT, guest, cameras.
- IoT and guest VLANs get **no** access to the LAN or management VLAN by default; allow only specific destinations (e.g. a Home Assistant host) via explicit rules.
- Guest networks use client isolation and a captive portal or PSK rotation.
- Cameras (Protect) go on an isolated VLAN with no internet unless a feature needs it.

## Firewall

- Default-deny inter-VLAN; add explicit allow rules for known flows.
- Order matters — UniFi evaluates top-down. Place specific allows above broad denies.
- Name every rule with intent ("IoT→HA:8123") so audits are readable.
- When auditing, look for: redundant rules, shadowed rules (never reached), any-any allows, and rules referencing deleted objects.

## WiFi

- WPA3 (or WPA2/3 transition) on all SSIDs; separate SSID per trust zone or use per-VLAN via RADIUS.
- Disable legacy 802.11b rates; set minimum RSSI to shed sticky clients only if roaming is a real problem.
- Keep channel width sane: 20/40 MHz on 2.4 GHz, 80 MHz on 5 GHz in dense areas.

## Auditing checklist

1. List networks/VLANs — confirm segmentation matches intent.
2. List firewall rules — flag redundant, shadowed, or any-any rules.
3. List clients per VLAN — flag devices on the wrong VLAN.
4. Check guest/IoT isolation is actually enforced.
5. Report findings; propose the minimal set of changes; apply one at a time on approval.
