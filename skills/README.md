# skills/

This directory holds the Claude Code skills shipped with the nautilus playbook.

It will fill out over time as skills prove themselves useful across projects. Right now the canonical workflow skills live in `skills-index.md` at the repo root, which is the quick-reference table. The per-skill assets in this directory are the loadable artifacts.

## Per-skill layout

Each skill is a directory under `skills/<skill-name>/`. At minimum it contains:

- `SKILL.md` — the loadable skill prose with frontmatter.
- Optional scripts, templates, or assets that the skill references. They live alongside `SKILL.md` and travel with it on install.

This is the same shape Claude Code expects under `~/.claude/skills/<name>/`, so the directory is copy-ready.

Suggested prose structure for the `SKILL.md` body:

- **When to invoke** — what trigger or situation calls for this skill.
- **What it does** — one paragraph summary of behavior.
- **Example invocations** — actual prompts that worked well.
- **Gotchas** — common failure modes, edge cases, things to know before relying on it.

## Sanitization expectations

Everything under `skills/` is public-facing. Strip these before merging:

- Local filesystem paths (`/home/...`, `/Users/...`).
- Private project, client, or person names.
- Credentials, tokens, API keys, internal hostnames.
- References to private repos or org-internal tooling.

If a skill is too tightly coupled to a private context to sanitize, leave it in `~/.claude/skills/` locally and skip the playbook copy.

## Adding a skill here

When a skill earns its place in the playbook (used across two or more projects, produced consistently good output), drop the sanitized directory in here, document it in this README's index if useful, and add a row to `skills-index.md`. Don't pre-populate with skills that haven't proven themselves — the index stays trustworthy if it only contains what actually works.

The `/nautilus-sync` skill automates the sanitize-and-copy step.

## Installing into `~/.claude/skills/`

User-level install via `install-tools.sh` at the repo root:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
```

That copies every skill directory in this folder into `$HOME/.claude/skills/` so Claude Code auto-loads them. Pass `--skills name1,name2` to install a subset, `--no-overwrite` to refuse to clobber existing copies, or `--dest DIR` to target a non-default home.
