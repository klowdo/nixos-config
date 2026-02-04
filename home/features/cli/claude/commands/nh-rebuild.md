---
allowed-tools: Bash(git:*), Bash(nix:*), Bash(nh:*)
description: Update NixOS flake inputs and rebuild the system
---

# NixOS Flake Rebuild

Update flake inputs and rebuild the NixOS system using nh (Nix Helper).

## Critical Rules

1. **NEVER commit to main** - Always use feature branches
2. **NEVER manually merge** - Use `gh pr merge --auto` instead

## Workflow

Follow these steps in order:

1. **Check current status**
   - !`git status`
   - !`git branch --show-current`

2. **Create feature branch if on main**
   - Create branch: `chore/flake-update-YYYY-MM-DD`

3. **Update flake inputs**
   - !`nix flake update`

4. **Check for changes**
   - !`git status`
   - If no changes, stop and report "No updates available"

5. **Commit changes**
   - !`git add flake.lock`
   - !`git commit -m "chore(deps): update flake.lock"`

6. **Test build first**
   - !`nh os test`
   - If test fails, report error and stop

7. **Apply changes**
   - !`nh os switch`

8. **Push and create PR**
   - !`git push -u origin HEAD`
   - Create PR with `dependencies` label
   - Enable auto-merge

9. **Report summary**
   - List updated inputs from flake.lock diff
   - Provide PR URL

## Important Notes

- Use `nh os test` to validate before switching
- Do not wait for CI checks - auto-merge handles this
- Return to main branch after PR creation
