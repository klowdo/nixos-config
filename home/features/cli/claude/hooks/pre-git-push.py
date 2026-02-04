#!/usr/bin/env python3
"""
Pre-git-push hook for NixOS configuration.

This hook intercepts git push commands and requires a successful
`nh os build` if .nix files were modified.

Exit codes:
  0 - Command proceeds normally
  2 - Push is blocked; build validation failed
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def is_nix_config_repo() -> bool:
    """Check if current repo is a nixos-config repository."""
    try:
        result = subprocess.run(
            ["git", "config", "--get", "remote.origin.url"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            return False
        remote_url = result.stdout.strip()
        return "nixos-config" in remote_url or "nix-config" in remote_url
    except Exception:
        return False


def get_changed_nix_files() -> list[str]:
    """Get list of .nix files changed compared to upstream."""
    try:
        # Get the upstream branch
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            # No upstream, compare to HEAD~1
            upstream = "HEAD~1"
        else:
            upstream = result.stdout.strip()

        # Get changed files using null-byte separator for safety
        result = subprocess.run(
            ["git", "diff", "--name-only", "-z", upstream],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            return []

        files = result.stdout.split("\0")
        return [f for f in files if f.endswith(".nix")]
    except Exception:
        return []


def run_nix_build() -> bool:
    """Run nh os build to validate configuration."""
    print("Running NixOS build validation...")
    try:
        result = subprocess.run(
            ["nh", "os", "build", "--dry"],
            timeout=600,  # 10 minute timeout
        )
        return result.returncode == 0
    except subprocess.TimeoutExpired:
        print("ERROR: Build validation timed out after 10 minutes")
        return False
    except FileNotFoundError:
        print("WARNING: nh command not found, skipping build validation")
        return True
    except Exception as e:
        print(f"ERROR: Build validation failed: {e}")
        return False


def is_automated_workflow() -> bool:
    """Check if running in an automated CI/CD context."""
    ci_vars = ["CI", "GITHUB_ACTIONS", "AUTOMATED_WORKFLOW", "AUTO_CLAUDE"]
    return any(os.environ.get(var) for var in ci_vars)


def main():
    # Parse hook input from stdin
    try:
        hook_input = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        # Not a valid hook input, allow command
        sys.exit(0)

    # Check if this is a git push command
    tool_input = hook_input.get("tool_input", {})
    command = tool_input.get("command", "")

    if "git push" not in command:
        # Not a push command, allow it
        sys.exit(0)

    # Skip in automated workflows
    if is_automated_workflow():
        print("Automated workflow detected, skipping build validation")
        sys.exit(0)

    # Check if this is a nixos-config repo
    if not is_nix_config_repo():
        # Not a nix config repo, allow push
        sys.exit(0)

    # Check for changed .nix files
    nix_files = get_changed_nix_files()
    if not nix_files:
        print("No .nix files changed, skipping build validation")
        sys.exit(0)

    print(f"Changed .nix files: {', '.join(nix_files)}")

    # Run build validation
    if run_nix_build():
        print("Build validation passed!")
        sys.exit(0)
    else:
        print("ERROR: Build validation failed. Push blocked.")
        print("Fix the build errors before pushing.")
        sys.exit(2)


if __name__ == "__main__":
    main()
