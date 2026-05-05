# Implementation Plan

## Phase 0 — Project scaffold

- [ ] Create CLI package skeleton.
- [ ] Add formatter, linter, test runner, and CI.
- [ ] Add sample Git-log fixture and golden-output test harness.

## Phase 1 — Git history ingestion

- [ ] Parse commits from a local repository path.
- [ ] Group commits by ISO week.
- [ ] Ignore merge noise and empty commit messages.

## Phase 2 — Digest generation

- [ ] Render grouped changes into Markdown.
- [ ] Separate fixes, features, maintenance, and follow-up items.
- [ ] Add golden tests for stable output.

## Phase 3 — CLI polish

- [ ] Add `--since`, `--until`, and `--output` flags.
- [ ] Document commands and examples.
- [ ] Validate errors for missing repos, empty history, and unwritable output paths.
