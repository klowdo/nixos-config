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
