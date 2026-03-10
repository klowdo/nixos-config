#!/bin/bash
set -euo pipefail

version="$1"

asset=$(curl -sL "https://api.github.com/repos/bambulab/BambuStudio/releases/tags/v${version}" |
	grep -o '"name" *: *"[^"]*ubuntu-24.04[^"]*"' | head -1 | sed 's/.*: *"//;s/"//')

pr_number="${asset//*PR-/}"
pr_number="${pr_number%%[.-]*}"

sed -i "s/pr = \"[0-9]*\";/pr = \"${pr_number}\";/" pkgs/bambustudio-appimage/default.nix

nix-shell -p nix-update --run "nix-update --version=skip --flake bambustudio-appimage"
