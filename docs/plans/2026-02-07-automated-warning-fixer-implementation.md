# Automated Warning Fixer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement automated Nix warning detection and fixing in the flake update workflow using Claude AI.

**Architecture:** Three Python scripts (warning parser, Claude fixer, orchestrator) integrated into existing GitHub Actions workflow. Uses pattern matching to detect warnings, Claude API to generate fixes, and validation loop to ensure fixes work.

**Tech Stack:** Python 3.11+, Anthropic SDK, GitHub Actions, Nix

---

## Task 1: Setup Scripts Directory and Dependencies

**Files:**
- Create: `.github/scripts/requirements.txt`
- Create: `.github/scripts/__init__.py`

**Step 1: Create scripts directory**

```bash
mkdir -p .github/scripts
```

**Step 2: Create requirements.txt**

```txt
anthropic>=0.18.0
```

**Step 3: Create __init__.py**

```python
"""
Scripts for automated Nix warning fixing in GitHub Actions.
"""
__version__ = "1.0.0"
```

**Step 4: Commit**

```bash
git add .github/scripts/requirements.txt .github/scripts/__init__.py
git commit -m "chore(ci): setup scripts directory for warning fixer"
```

---

## Task 2: Implement Warning Parser

**Files:**
- Create: `.github/scripts/parse_warnings.py`
- Create: `.github/scripts/test_parse_warnings.py`

**Step 1: Write the failing test**

```python
"""Tests for warning parser."""
import json
from parse_warnings import parse_nix_output, deduplicate_warnings


def test_parse_warning_basic():
    output = """
building...
warning: foo is deprecated, use bar instead
  at /home/user/flake.nix:42:5
continuing...
"""
    warnings = parse_nix_output(output)
    assert len(warnings) == 1
    assert warnings[0]["message"] == "warning: foo is deprecated, use bar instead"
    assert warnings[0]["file"] == "/home/user/flake.nix"
    assert warnings[0]["line"] == 42


def test_parse_trace_warning():
    output = """
trace: warning: obsolete option used
  at /home/user/config.nix:10:3
"""
    warnings = parse_nix_output(output)
    assert len(warnings) == 1
    assert "obsolete option used" in warnings[0]["message"]


def test_deduplicate_warnings():
    warnings = [
        {"id": "hash1", "message": "warn1", "file": "a.nix", "line": 10},
        {"id": "hash1", "message": "warn1", "file": "a.nix", "line": 10},
        {"id": "hash2", "message": "warn2", "file": "b.nix", "line": 20},
    ]
    deduplicated = deduplicate_warnings(warnings)
    assert len(deduplicated) == 2
```

**Step 2: Run test to verify it fails**

```bash
cd .github/scripts
python -m pytest test_parse_warnings.py -v
```

Expected: FAIL with "ModuleNotFoundError: No module named 'parse_warnings'"

**Step 3: Write minimal implementation**

```python
"""Parse Nix warnings from command output."""
import re
import hashlib
import json
from typing import List, Dict, Optional


WARNING_PATTERNS = [
    r"warning: (.+)",
    r"trace: warning: (.+)",
    r"deprecated: (.+)",
    r"note: (.+) is deprecated",
    r"error: (.+) (?:deprecated|obsolete)",
]

FILE_LOCATION_PATTERN = r"at (.+?):(\d+):(\d+)"


def parse_nix_output(output: str) -> List[Dict]:
    """Parse Nix output and extract warnings with context."""
    warnings = []
    lines = output.split("\n")

    for i, line in enumerate(lines):
        for pattern in WARNING_PATTERNS:
            match = re.search(pattern, line, re.IGNORECASE)
            if match:
                warning = {
                    "message": line.strip(),
                    "file": None,
                    "line": None,
                    "context": "",
                    "full_output": output,
                }

                # Look for file location in next few lines
                for j in range(i, min(i + 5, len(lines))):
                    loc_match = re.search(FILE_LOCATION_PATTERN, lines[j])
                    if loc_match:
                        warning["file"] = loc_match.group(1)
                        warning["line"] = int(loc_match.group(2))
                        break

                # Extract context (5 lines before and after)
                start = max(0, i - 5)
                end = min(len(lines), i + 6)
                warning["context"] = "\n".join(lines[start:end])

                # Generate ID
                id_str = f"{warning['message']}{warning['file']}{warning['line']}"
                warning["id"] = hashlib.md5(id_str.encode()).hexdigest()[:8]

                warnings.append(warning)
                break

    return warnings


def deduplicate_warnings(warnings: List[Dict]) -> List[Dict]:
    """Remove duplicate warnings based on ID."""
    seen = set()
    unique = []

    for warning in warnings:
        if warning["id"] not in seen:
            seen.add(warning["id"])
            unique.append(warning)

    return unique


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python parse_warnings.py <output_file>")
        sys.exit(1)

    with open(sys.argv[1], "r") as f:
        output = f.read()

    warnings = deduplicate_warnings(parse_nix_output(output))
    print(json.dumps(warnings, indent=2))
```

**Step 4: Run test to verify it passes**

```bash
cd .github/scripts
python -m pytest test_parse_warnings.py -v
```

Expected: PASS (3 tests)

**Step 5: Commit**

```bash
git add .github/scripts/parse_warnings.py .github/scripts/test_parse_warnings.py
git commit -m "feat(ci): add Nix warning parser with tests"
```

---

## Task 3: Implement Claude Fixer

**Files:**
- Create: `.github/scripts/claude_fixer.py`
- Create: `.github/scripts/test_claude_fixer.py`

**Step 1: Write the failing test**

```python
"""Tests for Claude fixer."""
import json
from unittest.mock import Mock, patch
from claude_fixer import ClaudeFixer, FixResult


def test_generate_fix_prompt():
    fixer = ClaudeFixer(api_key="test")
    warning = {
        "message": "warning: foo is deprecated",
        "file": "/path/file.nix",
        "line": 42,
        "context": "some context",
        "full_output": "full output"
    }

    prompt = fixer._generate_prompt(warning)
    assert "foo is deprecated" in prompt
    assert "/path/file.nix:42" in prompt
    assert "some context" in prompt


@patch('claude_fixer.Anthropic')
def test_fix_warning_success(mock_anthropic):
    mock_client = Mock()
    mock_anthropic.return_value = mock_client

    mock_response = Mock()
    mock_response.content = [Mock(text="Root cause: foo is old\n\nFix: use bar\n\nCommit: fix(nix): replace foo with bar")]
    mock_client.messages.create.return_value = mock_response

    fixer = ClaudeFixer(api_key="test")
    warning = {
        "message": "warning: foo is deprecated",
        "file": "/path/file.nix",
        "line": 42,
        "context": "foo = 1;",
        "full_output": ""
    }

    result = fixer.generate_fix(warning)
    assert result.status == "success"
    assert "use bar" in result.fix_content
    assert result.commit_message.startswith("fix(nix):")


@patch('claude_fixer.Anthropic')
def test_fix_warning_skip(mock_anthropic):
    mock_client = Mock()
    mock_anthropic.return_value = mock_client

    mock_response = Mock()
    mock_response.content = [Mock(text="SKIP: too complex to automate")]
    mock_client.messages.create.return_value = mock_response

    fixer = ClaudeFixer(api_key="test")
    warning = {"message": "complex warning", "file": None, "line": None, "context": "", "full_output": ""}

    result = fixer.generate_fix(warning)
    assert result.status == "skipped"
    assert "too complex" in result.reason
```

**Step 2: Run test to verify it fails**

```bash
cd .github/scripts
python -m pytest test_claude_fixer.py -v
```

Expected: FAIL with "ModuleNotFoundError: No module named 'claude_fixer'"

**Step 3: Write minimal implementation**

```python
"""Claude AI integration for fixing Nix warnings."""
import os
import re
from dataclasses import dataclass
from typing import Optional
from anthropic import Anthropic


@dataclass
class FixResult:
    """Result of a fix attempt."""
    status: str  # "success", "skipped", "failed"
    fix_content: Optional[str] = None
    commit_message: Optional[str] = None
    reason: Optional[str] = None
    analysis: Optional[str] = None


class ClaudeFixer:
    """Uses Claude AI to generate fixes for Nix warnings."""

    def __init__(self, api_key: str):
        self.client = Anthropic(api_key=api_key)

    def _generate_prompt(self, warning: dict) -> str:
        """Generate prompt for Claude."""
        file_loc = f"{warning['file']}:{warning['line']}" if warning['file'] else "unknown location"

        return f"""You are fixing a Nix configuration warning. Analyze the warning and provide a precise fix.

Warning: {warning['message']}
File: {file_loc}
Context:
{warning['context']}

Full output:
{warning['full_output'][:1000]}

Provide:
1. Root cause analysis (1-2 sentences)
2. The exact fix to apply
3. A conventional commit message following: fix(scope): brief description

Rules:
- Only modify what's necessary to fix this specific warning
- Preserve formatting and style
- If the warning suggests a replacement, use it
- If you cannot determine a safe fix, respond with "SKIP: reason"
"""

    def generate_fix(self, warning: dict) -> FixResult:
        """Generate a fix for the given warning."""
        try:
            prompt = self._generate_prompt(warning)

            response = self.client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=2000,
                messages=[{"role": "user", "content": prompt}]
            )

            content = response.content[0].text

            # Check for SKIP marker
            if content.startswith("SKIP:"):
                reason = content.replace("SKIP:", "").strip()
                return FixResult(status="skipped", reason=reason)

            # Parse response
            lines = content.split("\n")
            analysis = []
            fix_content = []
            commit_message = None

            section = None
            for line in lines:
                if "root cause" in line.lower() or "analysis" in line.lower():
                    section = "analysis"
                elif "fix:" in line.lower():
                    section = "fix"
                elif "commit:" in line.lower() or "commit message" in line.lower():
                    section = "commit"
                elif section == "analysis":
                    analysis.append(line)
                elif section == "fix":
                    fix_content.append(line)
                elif section == "commit":
                    if line.strip() and not commit_message:
                        commit_message = line.strip()

            return FixResult(
                status="success",
                fix_content="\n".join(fix_content).strip(),
                commit_message=commit_message or "fix: resolve Nix warning",
                analysis="\n".join(analysis).strip()
            )

        except Exception as e:
            return FixResult(status="failed", reason=str(e))


if __name__ == "__main__":
    import sys
    import json

    if len(sys.argv) < 2:
        print("Usage: python claude_fixer.py <warnings_json_file>")
        sys.exit(1)

    api_key = os.getenv("ANTHROPIC_API_KEY") or os.getenv("CLAUDE_API_KEY")
    if not api_key:
        print("Error: ANTHROPIC_API_KEY or CLAUDE_API_KEY must be set")
        sys.exit(1)

    with open(sys.argv[1], "r") as f:
        warnings = json.load(f)

    fixer = ClaudeFixer(api_key)
    results = []

    for warning in warnings:
        result = fixer.generate_fix(warning)
        results.append({
            "warning": warning,
            "result": {
                "status": result.status,
                "fix_content": result.fix_content,
                "commit_message": result.commit_message,
                "reason": result.reason,
                "analysis": result.analysis
            }
        })

    print(json.dumps(results, indent=2))
```

**Step 4: Run test to verify it passes**

```bash
cd .github/scripts
python -m pytest test_claude_fixer.py -v
```

Expected: PASS (3 tests)

**Step 5: Commit**

```bash
git add .github/scripts/claude_fixer.py .github/scripts/test_claude_fixer.py
git commit -m "feat(ci): add Claude fixer with API integration"
```

---

## Task 4: Implement Fix Orchestrator

**Files:**
- Create: `.github/scripts/fix_warnings.py`

**Step 1: Write orchestrator script**

```python
#!/usr/bin/env python3
"""
Orchestrate the warning fixing process:
1. Parse warnings from Nix output
2. Generate fixes using Claude
3. Apply and validate each fix
4. Generate summary report
"""
import os
import sys
import json
import subprocess
from pathlib import Path
from typing import List, Dict
from parse_warnings import parse_nix_output, deduplicate_warnings
from claude_fixer import ClaudeFixer, FixResult


class FixOrchestrator:
    """Orchestrates the warning fixing workflow."""

    def __init__(self, api_key: str, repo_root: str, max_fixes: int = 20):
        self.fixer = ClaudeFixer(api_key)
        self.repo_root = Path(repo_root)
        self.max_fixes = max_fixes
        self.results = {
            "total": 0,
            "fixed": 0,
            "skipped": 0,
            "failed": 0,
            "fixes": []
        }

    def run_nix_check(self) -> str:
        """Run nix flake check and capture output."""
        result = subprocess.run(
            ["nix", "flake", "check", "-L"],
            cwd=self.repo_root,
            capture_output=True,
            text=True,
            timeout=300
        )
        return result.stdout + result.stderr

    def apply_fix(self, warning: dict, fix_result: FixResult) -> bool:
        """Apply a fix to the target file."""
        if not warning.get("file") or not fix_result.fix_content:
            return False

        file_path = Path(warning["file"])
        if not file_path.is_absolute():
            file_path = self.repo_root / file_path

        if not file_path.exists():
            print(f"Warning: File not found: {file_path}")
            return False

        try:
            # For now, write fix instructions to a comment
            # Real implementation would use AST manipulation or sed
            print(f"Would apply fix to {file_path}")
            print(f"Fix content:\n{fix_result.fix_content}")
            return True
        except Exception as e:
            print(f"Error applying fix: {e}")
            return False

    def validate_fix(self, warning_id: str) -> bool:
        """Validate that the fix resolved the warning."""
        output = self.run_nix_check()
        new_warnings = parse_nix_output(output)

        # Check if original warning still present
        for w in new_warnings:
            if w["id"] == warning_id:
                return False
        return True

    def commit_fix(self, warning: dict, fix_result: FixResult):
        """Commit the fix with appropriate message."""
        file_path = warning.get("file", "unknown")

        subprocess.run(
            ["git", "add", file_path],
            cwd=self.repo_root,
            check=True
        )

        commit_msg = f"{fix_result.commit_message}\n\n{fix_result.analysis}\n\nAutomated fix suggested by Claude."

        subprocess.run(
            ["git", "commit", "-m", commit_msg],
            cwd=self.repo_root,
            check=True
        )

    def process_warning(self, warning: dict) -> Dict:
        """Process a single warning."""
        print(f"\nProcessing warning: {warning['id']}")
        print(f"Message: {warning['message']}")

        # Generate fix
        fix_result = self.fixer.generate_fix(warning)

        if fix_result.status == "skipped":
            print(f"Skipped: {fix_result.reason}")
            self.results["skipped"] += 1
            return {
                "warning": warning,
                "status": "skipped",
                "reason": fix_result.reason
            }

        if fix_result.status == "failed":
            print(f"Failed: {fix_result.reason}")
            self.results["failed"] += 1
            return {
                "warning": warning,
                "status": "failed",
                "reason": fix_result.reason
            }

        # Apply fix
        if not self.apply_fix(warning, fix_result):
            print("Failed to apply fix")
            self.results["failed"] += 1
            return {
                "warning": warning,
                "status": "failed",
                "reason": "Could not apply fix"
            }

        # Validate
        if not self.validate_fix(warning["id"]):
            print("Fix did not resolve warning, reverting")
            subprocess.run(["git", "restore", warning.get("file", ".")], cwd=self.repo_root)
            self.results["skipped"] += 1
            return {
                "warning": warning,
                "status": "skipped",
                "reason": "Fix did not resolve warning"
            }

        # Commit
        self.commit_fix(warning, fix_result)
        print("Successfully fixed and committed")
        self.results["fixed"] += 1
        return {
            "warning": warning,
            "status": "fixed",
            "commit_message": fix_result.commit_message
        }

    def run(self, nix_output_file: str) -> Dict:
        """Run the full orchestration."""
        # Parse warnings
        with open(nix_output_file, "r") as f:
            output = f.read()

        warnings = deduplicate_warnings(parse_nix_output(output))
        self.results["total"] = len(warnings)

        print(f"Found {len(warnings)} unique warnings")

        # Process each warning
        for i, warning in enumerate(warnings[:self.max_fixes]):
            result = self.process_warning(warning)
            self.results["fixes"].append(result)

        return self.results


def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_warnings.py <nix_output_file>")
        sys.exit(1)

    api_key = os.getenv("ANTHROPIC_API_KEY") or os.getenv("CLAUDE_API_KEY")
    if not api_key:
        print("Error: ANTHROPIC_API_KEY or CLAUDE_API_KEY must be set")
        sys.exit(1)

    repo_root = os.getenv("GITHUB_WORKSPACE", os.getcwd())

    orchestrator = FixOrchestrator(api_key, repo_root)
    results = orchestrator.run(sys.argv[1])

    # Write results
    with open("fix_results.json", "w") as f:
        json.dump(results, f, indent=2)

    print("\n" + "="*50)
    print("SUMMARY")
    print("="*50)
    print(f"Total warnings: {results['total']}")
    print(f"Fixed: {results['fixed']}")
    print(f"Skipped: {results['skipped']}")
    print(f"Failed: {results['failed']}")


if __name__ == "__main__":
    main()
```

**Step 2: Make script executable**

```bash
chmod +x .github/scripts/fix_warnings.py
```

**Step 3: Commit**

```bash
git add .github/scripts/fix_warnings.py
git commit -m "feat(ci): add fix orchestrator script"
```

---

## Task 5: Create PR Summary Generator

**Files:**
- Create: `.github/scripts/generate_pr_body.py`

**Step 1: Write summary generator**

```python
#!/usr/bin/env python3
"""Generate PR body from fix results."""
import json
import sys


def generate_pr_body(results: dict) -> str:
    """Generate markdown PR body."""
    fixed = [f for f in results["fixes"] if f["status"] == "fixed"]
    skipped = [f for f in results["fixes"] if f["status"] == "skipped"]
    failed = [f for f in results["fixes"] if f["status"] == "failed"]

    body = "## Automated Flake Update\n\n"
    body += "Flake inputs updated and warnings automatically resolved.\n\n"

    if fixed:
        body += f"### ✅ Successfully Fixed ({len(fixed)})\n"
        for fix in fixed:
            warning = fix["warning"]
            file_loc = f"{warning.get('file', 'unknown')}:{warning.get('line', '?')}"
            message = warning["message"].replace("warning: ", "").replace("trace: ", "")
            body += f"- `{message[:60]}...` in {file_loc}\n"
        body += "\n"

    needs_review = skipped + failed
    if needs_review:
        body += f"### ⚠️ Needs Manual Review ({len(needs_review)})\n"
        for item in needs_review:
            warning = item["warning"]
            reason = item.get("reason", "Unknown reason")
            file_loc = f"{warning.get('file', 'unknown')}:{warning.get('line', '?')}"
            message = warning["message"].replace("warning: ", "").replace("trace: ", "")
            body += f"- `{message[:60]}...` in {file_loc} - {reason}\n"
        body += "\n"

    body += "### 📊 Summary\n"
    body += f"- Total warnings detected: {results['total']}\n"
    body += f"- Automatically fixed: {results['fixed']}\n"
    body += f"- Requires manual attention: {results['skipped'] + results['failed']}\n\n"

    workflow_url = f"${{github.server_url}}/${{github.repository}}/actions/runs/${{github.run_id}}"
    body += f"[View detailed logs]({workflow_url})\n\n"
    body += "---\n"
    body += "🤖 Generated by automated flake update workflow\n"

    return body


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_pr_body.py <results_json_file>")
        sys.exit(1)

    with open(sys.argv[1], "r") as f:
        results = json.load(f)

    print(generate_pr_body(results))


if __name__ == "__main__":
    main()
```

**Step 2: Make executable and commit**

```bash
chmod +x .github/scripts/generate_pr_body.py
git add .github/scripts/generate_pr_body.py
git commit -m "feat(ci): add PR summary generator"
```

---

## Task 6: Integrate into GitHub Workflow

**Files:**
- Modify: `.github/workflows/update-flake.yml`

**Step 1: Read current workflow**

```bash
cat .github/workflows/update-flake.yml
```

**Step 2: Add warning fixing steps after flake update**

Add these steps after the "Update flake.lock" step (line 30-31):

```yaml
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install Python dependencies
        run: |
          pip install -r .github/scripts/requirements.txt

      - name: Run initial check and capture warnings
        id: initial-check
        continue-on-error: true
        run: |
          nix flake check -L 2>&1 | tee nix_output.txt
          echo "check_exit_code=$?" >> $GITHUB_OUTPUT

      - name: Parse and fix warnings
        if: steps.initial-check.outputs.check_exit_code != '0'
        env:
          ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          GITHUB_WORKSPACE: ${{ github.workspace }}
        run: |
          # Configure git
          git config user.name "${{ github.actor }}"
          git config user.email "${{ github.actor }}@users.noreply.github.com"

          # Run fix orchestrator
          python .github/scripts/fix_warnings.py nix_output.txt

      - name: Final validation check
        run: nix flake check -L

      - name: Generate PR body
        id: pr-body
        run: |
          if [ -f fix_results.json ]; then
            PR_BODY=$(python .github/scripts/generate_pr_body.py fix_results.json)
            echo "pr_body<<EOF" >> $GITHUB_OUTPUT
            echo "$PR_BODY" >> $GITHUB_OUTPUT
            echo "EOF" >> $GITHUB_OUTPUT
          else
            echo "pr_body=Automated flake.lock update." >> $GITHUB_OUTPUT
          fi
```

**Step 3: Update PR creation step**

Modify the "Create Pull Request" step (around line 36) to use the generated body:

```yaml
      - name: Create Pull Request
        id: create-pr
        uses: peter-evans/create-pull-request@v8
        with:
          token: ${{ secrets.GH_PAT }}
          commit-message: "chore(flake): update flake.lock"
          title: "chore(flake): update flake.lock"
          body: ${{ steps.pr-body.outputs.pr_body }}
          branch: auto-update-flake-lock
          delete-branch: true
```

**Step 4: Update auto-merge condition**

Modify the "Enable auto-merge" step to only auto-merge if all warnings fixed:

```yaml
      - name: Enable auto-merge
        if: steps.create-pr.outputs.pull-request-number
        run: |
          # Only auto-merge if all warnings were fixed
          if [ -f fix_results.json ]; then
            SKIPPED=$(jq '.skipped + .failed' fix_results.json)
            if [ "$SKIPPED" -eq 0 ]; then
              gh pr merge --auto --rebase "${{ steps.create-pr.outputs.pull-request-number }}"
            else
              echo "Warnings require manual review, skipping auto-merge"
            fi
          else
            gh pr merge --auto --rebase "${{ steps.create-pr.outputs.pull-request-number }}"
          fi
        env:
          GH_TOKEN: ${{ secrets.GH_PAT }}
```

**Step 5: Commit workflow changes**

```bash
git add .github/workflows/update-flake.yml
git commit -m "feat(ci): integrate warning fixer into update workflow"
```

---

## Task 7: Add Documentation

**Files:**
- Create: `.github/scripts/README.md`

**Step 1: Write README**

```markdown
# Automated Nix Warning Fixer

Scripts for automatically detecting and fixing Nix warnings during flake updates.

## Overview

The warning fixer system:
1. Parses warnings from `nix flake check` output
2. Uses Claude AI to generate fixes
3. Validates each fix
4. Commits fixes individually with conventional commit messages
5. Generates summary for PR review

## Scripts

- `parse_warnings.py` - Extract and deduplicate warnings from Nix output
- `claude_fixer.py` - Generate fixes using Claude API
- `fix_warnings.py` - Orchestrate the fixing process
- `generate_pr_body.py` - Create PR summary

## Usage

### Manually run warning fixer

```bash
# Run nix check and capture output
nix flake check -L 2>&1 | tee nix_output.txt

# Set API key
export ANTHROPIC_API_KEY="your-key"

# Run fixer
python .github/scripts/fix_warnings.py nix_output.txt

# Generate PR body
python .github/scripts/generate_pr_body.py fix_results.json
```

### Test individual components

```bash
cd .github/scripts

# Install dependencies
pip install -r requirements.txt pytest

# Run tests
pytest test_*.py -v
```

## Configuration

Set these secrets in GitHub:
- `CLAUDE_CODE_OAUTH_TOKEN` - Claude API access (already configured)
- `GH_PAT` - GitHub personal access token (already configured)

## Safety Features

- Maximum 20 fix attempts per run
- 5 minute timeout per fix
- Validation after each fix
- Automatic revert if fix doesn't work
- Manual review required if any warnings can't be fixed

## Design

See `docs/plans/2026-02-07-automated-warning-fixer-design.md` for detailed design documentation.
```

**Step 2: Commit documentation**

```bash
git add .github/scripts/README.md
git commit -m "docs(ci): add warning fixer documentation"
```

---

## Task 8: Add .gitignore entries

**Files:**
- Modify: `.gitignore`

**Step 1: Add Python artifacts to .gitignore**

Add these lines to `.gitignore`:

```
# Python
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/

# Warning fixer outputs
nix_output.txt
fix_results.json
```

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: ignore Python artifacts and fixer outputs"
```

---

## Success Criteria

- [ ] All Python scripts have tests
- [ ] Tests pass locally
- [ ] Workflow syntax is valid (check with `actionlint` if available)
- [ ] Scripts are executable
- [ ] Documentation is complete
- [ ] Git ignores generated files

## Testing Strategy

### Unit Tests
- Test warning parser with various Nix output formats
- Test Claude fixer with mocked API responses
- Test PR body generator with sample results

### Integration Test
- Manually trigger workflow on a test branch
- Verify warnings are detected and fixed
- Check commit messages follow conventional format
- Verify PR body is generated correctly

### Manual Validation
```bash
# Run scripts locally
nix flake check -L 2>&1 | tee test_output.txt
python .github/scripts/parse_warnings.py test_output.txt
```

## Notes

- The orchestrator's `apply_fix()` method currently just prints the fix. A production implementation would need proper file editing logic (AST manipulation or intelligent text replacement).
- Consider using `@superpowers:verification-before-completion` before claiming tasks complete.
- Use `@superpowers:systematic-debugging` if tests fail.
