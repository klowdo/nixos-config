---
name: pkgs-update-tags
description: Use when creating or reviewing a package under pkgs/ or an overlays/jetbrains-*.nix in this dotfiles repo. Ensures the correct automated-update marker comment (`# nix-update:` or `# renovate:`) is placed on line 1 so the daily nix-update workflow or Renovate customManager picks it up.
---

# pkgs update-tags

Every package under `pkgs/` in this repo needs a marker comment on **line 1** of its `default.nix`, or it will silently never be updated. Two systems consume these markers:

- **`# nix-update: <pname>`** — default. Discovered by `.github/workflows/nix-update.yml` (daily cron at 06:00 UTC + `workflow_dispatch`) via `grep -rh '# nix-update:' --include='*.nix'`. Each match runs `nix-update --flake <pname>` and opens an auto-merging `chore(nix-update): bump <pname>` PR.
- **`# renovate: <depName> [code=<CODE>]`** — exception. Only works in combination with a matching `customManagers` regex block in `.github/renovate-nix.json5`. Use **only** when `nix-update` cannot handle the case.

## Decision rule

1. **Default — `# nix-update: <pname>`.** Applies to every new `pkgs/*/default.nix`, including ordinary appimages (see `pkgs/auto-claude-appimage/default.nix`). Single argument = the attr name registered in `pkgs/default.nix`. No flags.

2. **Exception A — JetBrains overlay** (`overlays/jetbrains-*.nix`):
   ```nix
   # renovate: jetbrains-<name> code=<CODE>
   ```
   `<CODE>` is the JetBrains product code (e.g. `RD`, `DG`, `GO`). Requires a matching `customManagers` entry in `.github/renovate-nix.json5` using the `custom.jetbrains-versions` and `custom.jetbrains-builds` datasources already defined there. Don't add a new JetBrains product without extending that config.

3. **Exception B — post-upgrade script required** (the `bambustudio-appimage` case):
   ```nix
   # renovate: <pname>
   ```
   Justified **only** when the update needs work `nix-update` cannot do — e.g. rewriting a second hash via `.github/scripts/<pname>-post-upgrade.sh` called from `postUpgradeTasks` in renovate config. Requires, in the same commit:
   - a `customManagers` entry in `.github/renovate-nix.json5` whose `managerFilePatterns` matches the file and whose regex captures `currentValue`,
   - a `packageRules` entry with `postUpgradeTasks.commands` and `fileFilters`,
   - the post-upgrade script under `.github/scripts/`.

If neither exception applies, use `# nix-update:`. Don't reach for `# renovate:` just because the upstream is on GitHub — `nix-update` handles `fetchFromGitHub` natively.

## Template

First two lines of a new `pkgs/<pname>/default.nix`:

```nix
# nix-update: <pname>
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
```

The marker must be line 1, above the function signature. Also register the attr in `pkgs/default.nix` — `nix-update --flake <pname>` errors if the attr doesn't exist, and the workflow treats that as a hard matrix failure.

## Canonical examples in this repo

- `pkgs/tmux-file-picker/default.nix` — standard `# nix-update:` on a `fetchFromGitHub` source.
- `pkgs/auto-claude-appimage/default.nix` — `# nix-update:` on an appimage (appimages do **not** need renovate).
- `pkgs/bambustudio-appimage/default.nix` — `# renovate:` because a post-upgrade hash rewrite is required.
- `overlays/jetbrains-rider.nix` — `# renovate: jetbrains-rider code=RD` with matching `customManagers` entry.

## Key files to cross-reference

- `.github/workflows/nix-update.yml` — discovery + execution of `# nix-update:` markers.
- `.github/renovate-nix.json5` — `customDatasources`, `customManagers`, and `postUpgradeTasks` for the `# renovate:` path.
- `pkgs/default.nix` — attr registration required for every new package.

## Verification before committing

```sh
# 1. Marker is on line 1
head -1 pkgs/<pname>/default.nix

# 2. Workflow discovery would pick it up (mirrors nix-update.yml)
grep -rh '# nix-update:' --include='*.nix' . | sort -u | grep <pname>

# 3. Attr is registered
grep <pname> pkgs/default.nix

# 4. Flake eval works (what nix-update does first)
nix eval .#<pname>.version --raw
```

If using `# renovate:` instead, also confirm:

```sh
# customManager covers the file
grep -A2 <pname> .github/renovate-nix.json5
```

After merge, the daily `nix-update` workflow runs at 06:00 UTC; trigger it manually with `gh workflow run nix-update.yml` and expect a `chore(nix-update): bump <pname>` PR labelled `nix-update`.

## Common mistakes

- **Marker not on line 1** — `grep` still finds it, but the repo convention is line 1. Stay consistent with existing packages.
- **Using `# renovate:` for a standard `fetchFromGitHub`** — creates dead custom-manager config and splits the update path for no reason. Use `# nix-update:`.
- **`# renovate:` comment without a matching `customManagers` entry** — Renovate silently does nothing. Always edit `.github/renovate-nix.json5` in the same commit.
- **Forgetting `pkgs/default.nix`** — the marker alone isn't enough; the attr must exist or `nix-update --flake <pname>` errors out in CI.
- **Choosing renovate because "it's an appimage"** — appimages work fine with `nix-update`; see `auto-claude-appimage`. Renovate is only for the post-upgrade-script case.
