---
allowed-tools: Bash(git:*), Bash(nix:*), Bash(nh:*), Read, Grep, Glob, Edit
description: Add a package to the NixOS configuration
---

# Quick Add Package

Add a new package to the NixOS configuration following best practices.

## Workflow

### 1. Verify Package Availability

**Search nixpkgs first:**
- Use the nixos MCP to verify the package exists
- Check package name and availability

**If not in nixpkgs:**
- Consider adding an overlay or custom package in `pkgs/`

### 2. Determine Installation Location

Based on package type, add to the appropriate location:

| Package Type | Location |
|--------------|----------|
| System-wide tools | `hosts/common/core/default.nix` or host-specific config |
| User CLI tools | `home/features/cli/default.nix` or feature-specific module |
| Desktop applications | `home/features/desktop/` or appropriate feature module |
| Development tools | `home/features/development/` |

### 3. Create Feature Branch

```bash
git checkout -b feat/add-<package-name>
```

### 4. Edit Configuration

Add the package to the appropriate `.nix` file.

**Example for Home Manager:**
```nix
home.packages = with pkgs; [
  # ... existing packages
  new-package-name
];
```

### 5. Validate Configuration

```bash
nix flake check
nh os test
```

### 6. Commit and Create PR

```bash
git add .
git commit -m "feat: add <package-name> package"
git push -u origin HEAD
```

## Critical Rules

- **NEVER** rebuild or merge without explicit user approval
- **ALWAYS** run `nix flake check` before committing
- **ALWAYS** test with `nh os test` before switching
- Pre-commit hooks must run without being bypassed

## Files to Reference

@hosts/common/core/default.nix
@home/features/cli/default.nix
