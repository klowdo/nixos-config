#!/bin/bash
set -euo pipefail

export USER="${USER:-root}"

curl --proto '=https' --tlsv1.2 -sSf -L \
	https://install.determinate.systems/nix | sh -s -- install linux \
	--extra-conf "sandbox = false" \
	--init none \
	--no-confirm

# shellcheck source=/dev/null
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix-daemon &
sleep 1

CACHIX_AUTH_TOKEN="${RENOVATE_CACHIX_AUTH_TOKEN:-}" \
	nix-shell -p cachix --run "cachix use klowdo"

renovate
