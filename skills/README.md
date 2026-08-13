# skills/

This directory holds Agent Skills-compatible workflows shipped with the nautilus playbook. Most are portable across harnesses; runtime-specific skills state their compatibility in frontmatter and prose.

It will fill out over time as skills prove themselves useful across projects. Right now the canonical workflow skills live in `skills-index.md` at the repo root, which is the quick-reference table. The per-skill assets in this directory are the loadable artifacts.

## Per-skill layout

Each skill is a directory under `skills/<skill-name>/`. At minimum it contains:

- `SKILL.md` — the loadable skill prose with frontmatter.
- Optional scripts, templates, or assets that the skill references. They live alongside `SKILL.md` and travel with it on install.

This is the directory shape used by Claude Code, Codex, and Pi's Agent Skills support, so each skill remains copy-ready.

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

## Installing skills

Claude Code user-level install:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
```

Pi user-level install for Pi-native skills:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- \
  --skills pi-implement,pi-review --agents none --dest "$HOME/.agents"
```

The first command installs under `$HOME/.claude/`; the Pi command installs under `$HOME/.agents/`, whose `skills/` directory Pi discovers globally. Pass `--skills name1,name2` to select a subset or `--no-overwrite` to refuse conflicts. Invoke the installed workflows as `/skill:pi-implement` and `/skill:pi-review`. They require `pi-subagents` 0.46.0 or newer.
