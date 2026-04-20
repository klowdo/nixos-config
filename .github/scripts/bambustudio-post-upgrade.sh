#!/bin/bash
set -euo pipefail

version="$1"
pkg="pkgs/bambustudio-appimage/default.nix"

asset=$(curl -sL "https://api.github.com/repos/bambulab/BambuStudio/releases/tags/v${version}" |
	grep -oP '"name"\s*:\s*"\K[^"]*ubuntu-24\.04[^"]*\.AppImage' | head -1)

if [ -z "$asset" ]; then
	echo "ERROR: no ubuntu-24.04 AppImage asset found for v${version}" >&2
	exit 1
fi

sed -i "s|asset = \".*\";|asset = \"${asset}\";|" "$pkg"

nix-shell -p nix-update --run "nix-update --version=skip --flake bambustudio-appimage"
