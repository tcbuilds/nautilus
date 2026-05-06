# Implementation Plan

Each phase ships a thin vertical slice of the product — end-to-end, testable, and usable on its own. No "scaffold first, features later." If the foundation needs work, it gets built inside the slice that needs it.

## Phase 1 — Walking skeleton

Smallest possible end-to-end pipeline. The output is a usable digest, even if it ignores most real-world variation.

- [ ] Read commits from a fixture repository checked into the test suite.
- [ ] Group commits by ISO week using a fixed grouping function.
- [ ] Emit a hardcoded Markdown digest with one section per week.
- [ ] Add one golden-file test that compares stdout to a committed expected digest.
- [ ] Wire up formatter, linter, and test runner so the gate stays green from the start.

Exit when running the CLI against the fixture repo produces the golden digest byte-for-byte.

## Phase 2 — Real classification

Real digests separate fixes from features from maintenance. This phase teaches the digest to read commit messages and route them.

- [ ] Parse commit messages with a deterministic classifier (Conventional Commits prefix, fallback heuristic).
- [ ] Update the Markdown template to render distinct sections for fixes, features, and maintenance.
- [ ] Add three golden tests covering the new buckets, plus an unclassified-commits fallback test.
- [ ] Document the classifier rules in `README.md` so users can predict where a commit lands.

Exit when the digest accurately classifies every commit in the fixture and the buckets are stable across runs.

## Phase 3 — Date filtering

Users want to scope the digest to a window. This phase adds the flags and end-to-end coverage.

- [ ] Add `--since` and `--until` flags accepting ISO dates.
- [ ] Filter commits before grouping so the rest of the pipeline stays unchanged.
- [ ] Add an end-to-end test that runs against a 30-day window over the fixture and asserts only that window's commits appear.
- [ ] Document the flags and provide one usage example in `README.md`.

Exit when a date-windowed run against the fixture produces only commits in range, and the golden test for the unbounded run still passes.

## Phase 4 — Output flag and validation

Last slice ships file output and the error paths that make the CLI trustworthy.

- [ ] Add `--output PATH` to write the digest to a file instead of stdout.
- [ ] Validate and surface clear errors for missing repository, empty history, and unwritable output paths.
- [ ] Add one test per error path covering exit code, message, and the absence of partial writes.
- [ ] Update `README.md` examples and ship a usage block that walks through `--since`, `--until`, and `--output` together.

Exit when each error path has a covering test, the happy-path file output matches the stdout golden, and the CLI is usable end-to-end against a real repository.
