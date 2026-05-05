# CLAUDE.md — Release Notes Digest

Project-level instructions for AI-assisted work in this example project.

## Product boundary

This is a local CLI for generating Markdown release digests from Git history. Do not add hosted services, accounts, databases, telemetry, or external AI calls without an explicit roadmap change.

## Engineering rules

- Prefer deterministic parsing over heuristic prose extraction.
- Keep generated Markdown stable so it can be tested with golden files.
- Treat repository contents as sensitive local data.
- Add regression tests for every parsing bug.
- Keep CLI commands documented in `README.md`.

## Verification

Before a change is considered done:

- Unit tests pass.
- Golden output snapshots are updated only when behavior intentionally changes.
- A sample digest is generated from the fixture repository.
