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
