# Automated Nix Warning Fixer Design

**Date**: 2026-02-07
**Status**: Approved
**Author**: Claude (brainstorming session with @klowdo)

## Overview

Extend the existing `update-flake.yml` GitHub Actions workflow to automatically detect and fix Nix warnings and deprecations during flake updates. The system uses Claude AI via the existing OAuth token to analyze warnings, propose fixes, validate them, and commit each fix separately in the user's name.

## Design Decisions

- **Authentication**: Reuse existing `CLAUDE_CODE_OAUTH_TOKEN`
- **PR Structure**: One PR with multiple commits (one per warning fixed)
- **Error Handling**: Skip unfixable warnings, continue with others, provide summary
- **Scope**: Fix all warnings including build warnings (comprehensive)
- **Validation**: Quick validation with `nix flake check` after each fix
- **Detection**: Pattern matching with regex for common warning formats
- **Commits**: User's identity with conventional commit format

## Architecture

### Workflow Flow

1. **Update Phase**: Standard `nix flake update` updates flake.lock
2. **Detection Phase**: Run `nix flake check` and capture all output, parse for warnings
3. **Fixing Phase**: For each warning, invoke Claude to analyze and propose a fix
4. **Validation Phase**: After each fix, run `nix flake check` to verify resolution
5. **PR Phase**: Create single PR with all commits (update + individual fixes)

### Components

1. **Warning Parser Script** (Python): Extracts warnings from Nix output
2. **Claude Fixer Script** (Python): Uses Anthropic SDK to generate and apply fixes
3. **Validation Loop**: Checks after each fix, skips if ineffective
4. **Summary Generator**: Creates PR comment with fix results

## Warning Detection & Parsing

### Warning Patterns

```regex
- /warning: .*/
- /trace: warning: .*/
- /deprecated: .*/
- /note: .* is deprecated/
- /error: .* (deprecated|obsolete)/
```

### Context Extraction

For each warning, capture:
- **Warning message**: Full warning text
- **File location**: Parse "at /path/to/file.nix:line:col" if present
- **Surrounding context**: 5 lines before/after for hints
- **Stack trace**: Any evaluation stack trace

### Output Format

```json
{
  "id": "warn_001",
  "message": "warning: foo is deprecated, use bar instead",
  "file": "/home/klowdo/.dotfiles/flake.nix",
  "line": 42,
  "context": "...surrounding code...",
  "full_output": "...complete error output..."
}
```

### Deduplication

Hash warnings by `(message + file + line)` to avoid duplicate fixes.

## Claude Fix Generation

### Prompt Template

```
You are fixing a Nix configuration warning. Analyze the warning and provide a precise fix.

Warning: {warning_message}
File: {file_path}:{line_number}
Context:
{surrounding_code}

Full output:
{full_nix_output}

Provide:
1. Root cause analysis (1-2 sentences)
2. The exact fix to apply
3. A conventional commit message following: fix(scope): brief description

Rules:
- Only modify what's necessary to fix this specific warning
- Preserve formatting and style
- If the warning suggests a replacement, use it
- If you cannot determine a safe fix, respond with "SKIP: reason"
```

### Response Parsing

- **SKIP marker**: Log as unfixable, continue to next warning
- **Fix content**: Extract code changes to apply
- **Commit message**: Use Claude's conventional commit message

### Fix Application

- If warning specifies file: apply fix directly
- If no file (flake-level): analyze context to determine target
- Stage changes with git

## Validation & Commit Logic

### Validation Steps

1. Apply Claude's fix to target file(s)
2. Stage changes: `git add <files>`
3. Run check: `nix flake check -L 2>&1 | tee check_output.txt`
4. Re-parse output to check if warning is gone
5. Decision:
   - Warning gone → Commit
   - Warning persists → Revert (`git restore`), mark SKIPPED
   - New errors → Revert, mark FAILED

### Commit Process

```bash
# Configure git identity
git config user.name "Your Name"
git config user.email "your-email@example.com"

# Commit with conventional format
git commit -m "fix(scope): resolve deprecation warning

{claude_analysis}

Automated fix suggested by Claude."
```

### Safety Checks

- Maximum 20 fix attempts per workflow run
- Timeout of 5 minutes per fix attempt
- Revert all changes if final `nix flake check` fails completely

## PR Creation & Summary Reporting

### Final PR Structure

```
Commit 1: chore(flake): update flake.lock
Commit 2: fix(flake): resolve 'foo' deprecation warning
Commit 3: fix(pkgs): update obsolete buildInputs syntax
Commit 4: fix(home): replace deprecated option X with Y
```

### PR Body Template

```markdown
## Automated Flake Update

Flake inputs updated and warnings automatically resolved.

### ✅ Successfully Fixed (N)
- `foo deprecation` in flake.nix:42 - Replaced with bar
- `obsolete buildInputs` in pkgs/example.nix:15 - Updated syntax
- `deprecated option` in home/config.nix:89 - Migrated to new option

### ⚠️ Needs Manual Review (M)
- `complex migration` in modules/foo.nix:123 - Unable to determine safe fix
- `ambiguous warning` - No file location provided

### 📊 Summary
- Total warnings detected: X
- Automatically fixed: N
- Requires manual attention: M

[View detailed logs](workflow_run_url)

---
🤖 Generated by automated flake update workflow
```

### Auto-merge Behavior

- Enable auto-merge ONLY if all warnings were fixed (`skipped_count == 0`)
- Otherwise, leave for manual review

## Implementation Notes

### Required Secrets

- `CLAUDE_CODE_OAUTH_TOKEN` (already exists)
- User git name/email (can use `github.actor` or add secrets)

### Dependencies

- Python 3.11+
- `anthropic` Python SDK
- Standard Nix tooling

### File Structure

```
.github/
  workflows/
    update-flake.yml           # Modified workflow
  scripts/
    parse-warnings.py          # Warning parser
    claude-fixer.py            # Claude integration
    apply-fix.sh               # Fix application script
```

## Success Criteria

- Workflow automatically fixes common deprecation warnings
- Each fix is a separate, well-documented commit
- Unfixable warnings are clearly reported for manual review
- No false positives (fixes that break the build)
- PR provides clear summary of what was done

## Future Enhancements

- Add retry logic (let Claude try again with new error output)
- Expand to other warning types (security advisories, outdated packages)
- Learn from successful fixes to improve prompts over time
- Integration with issue tracking for persistent warnings
