# skills/

This directory documents the Claude Code skills used in the nautilus workflow.

It will fill out over time as skills prove themselves useful across projects. Right now the canonical workflow skills live in `skills-index.md` at the repo root, which is the quick-reference table. The per-skill files in this directory go deeper.

## Per-skill file format

Each skill gets its own markdown file. Suggested structure:

- **Name** — the slash command (e.g. `/refine-spec`).
- **When to invoke** — what trigger or situation calls for this skill.
- **What it does** — one paragraph summary of behavior.
- **Example invocations** — actual prompts that worked well.
- **Gotchas** — common failure modes, edge cases, things to know before relying on it.

## Adding a skill here

When a skill earns its place in the playbook (used across two or more projects, produced consistently good output), document it here and add a row to `skills-index.md`. Don't pre-populate with skills that haven't proven themselves — the index stays trustworthy if it only contains what actually works.
