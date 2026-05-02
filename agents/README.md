# agents/

This directory documents the specialized Claude Code agents used in the nautilus workflow.

It will fill out over time as agents prove themselves across projects. The quick-reference table lives in `agents-index.md` at the repo root. The per-agent files in this directory go deeper.

## Per-agent file format

Each agent gets its own markdown file. Suggested structure:

- **Name** — the agent identifier (e.g. `github-master`, `python-core-engineer`).
- **What it's for** — the specialty in one sentence.
- **When to delegate to it** — situations and signals that should trigger using it.
- **Example briefs that worked well** — actual prompts that produced strong results.
- **Anti-patterns** — when *not* to use it, what tasks it tends to over-scope or under-deliver on.

## Adding an agent here

When an agent earns its place (used across two or more projects, produced consistently good output, materially better than doing the work in the orchestrator), document it here and add a row to `agents-index.md`. Keep both lists honest by only including agents that have proven themselves.
