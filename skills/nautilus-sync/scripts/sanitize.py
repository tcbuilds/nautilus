#!/usr/bin/env python3
"""Stdin to stdout sanitizer for nautilus-sync.

Strips personal/project-specific identifiers from skill or agent source files
before they are copied into a public-facing playbook repo.

Usage:
    cat ~/.claude/skills/<name>/SKILL.md | sanitize.py
    cat ~/.claude/agents/<name>.md | sanitize.py

Stats printed to stderr; sanitized content printed to stdout.

The substitution table below is a starter set. Fork this file and extend the
SUBSTITUTIONS list with your own private identifiers (project names, internal
hostnames, brand names, codenames, personal emails) before relying on this
filter for anything you intend to publish. Treat the final `rg` pass in the
parent skill as the real safety net, not these regexes.
"""

from __future__ import annotations

import re
import sys
from collections import Counter

SUBSTITUTIONS: list[tuple[str, str, str]] = [
    (r"/home/[A-Za-z0-9_.-]+/", "~/", "path"),
    (r"/Users/[A-Za-z0-9_.-]+/", "~/", "path"),
    (r"\bhome/[A-Za-z0-9_.-]+\b", "$HOME", "path"),
]

KEY_LINE = re.compile(
    r"(?im)^(.*(?:api[_-]?key|secret|token|indexnow.*key)\s*[:=]\s*)[\"']?([0-9a-fA-F]{32,})[\"']?\s*$"
)

BARE_HEX = re.compile(r"\b[0-9a-fA-F]{32,}\b")

BADGES_TRAILER = re.compile(
    r"(?ms)\n*##?\s*(?:Status|Badge).*?readme-status-badges.*?(?=\n##\s|\Z)"
)
BADGES_INLINE = re.compile(
    r"(?m)^\s*python3?\s+~?/?\.?[\w./-]*readme-status-badges/scripts/[\w./-]+.*$\n?"
)


def sanitize(text: str) -> tuple[str, Counter]:
    stats: Counter = Counter()

    for pattern, repl, tag in SUBSTITUTIONS:
        new_text, n = re.subn(pattern, repl, text)
        if n:
            stats[tag] += n
            text = new_text

    text, n = KEY_LINE.subn(r"\1<redacted-generate-your-own>", text)
    if n:
        stats["api_key"] += n

    text, n = BARE_HEX.subn("<redacted-hex>", text)
    if n:
        stats["bare_hex"] += n

    text, n = BADGES_TRAILER.subn("", text)
    if n:
        stats["badges_trailer"] += n
    text, n = BADGES_INLINE.subn("", text)
    if n:
        stats["badges_trailer"] += n

    return text, stats


def main() -> int:
    raw = sys.stdin.read()
    sanitized, stats = sanitize(raw)
    sys.stdout.write(sanitized)
    sys.stderr.write("sanitize stats:\n")
    for tag, count in sorted(stats.items()):
        sys.stderr.write(f"  {tag}: {count}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
