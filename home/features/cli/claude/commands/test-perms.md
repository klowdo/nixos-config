---
allowed-tools: Read, Glob, Grep, Bash(jq:*), Bash(whoami), Bash(git --version), Bash(git status), Bash(node --version), Bash(python3 --version), Bash(nix --version), Bash(nh --version)
description: Validate Claude Code permissions are configured and functional
---

# Test Permissions

Validate that Claude Code permissions are configured correctly and functional.

## Objective

Test that permissions work without triggering authorization dialogs during command execution.

## Validation Steps

### 1. Check Settings File

Examine `~/.claude/settings.json`:
- Verify valid JSON structure
- Check permission entries exist

### 2. Execute Single Authorized Command

Run one command that should be allowed:
- !`whoami`

### 3. Execute Multiple Commands in Parallel

Run these simultaneously:
- !`git --version`
- !`node --version`
- !`python3 --version`
- !`nix --version`
- !`nh --version`

### 4. Test File Operations

Test allowed file operations:
- Read a configuration file
- Search with glob pattern
- Search with grep

### 5. Success Criteria

The test is **successful** if:
- All commands execute without permission prompts
- File operations complete without errors
- No authorization dialogs appeared

## Report

Provide a summary:
- Number of commands tested
- Success/failure status for each
- Any permissions that need adjustment
