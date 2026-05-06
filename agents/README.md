# agents/

This directory holds the specialized Claude Code agents shipped with the nautilus playbook.

It will fill out over time as agents prove themselves across projects. The quick-reference table lives in `agents-index.md` at the repo root. The per-agent files in this directory are the loadable artifacts.

## Per-agent layout

Each agent is a single markdown file at `agents/<agent-name>.md`. The file starts with frontmatter that Claude Code parses (name, description, model, tools, etc.) followed by the system prompt body that defines the agent's behavior.

This is the same shape Claude Code expects under `~/.claude/agents/<name>.md`, so each file is copy-ready.

Suggested prose structure for the body:

- **What it's for** — the specialty in one sentence.
- **When to delegate to it** — situations and signals that should trigger using it.
- **Operating guidelines** — how the agent should approach work, what standards to follow.
- **Example briefs that worked well** — actual prompts that produced strong results.
- **Anti-patterns** — when *not* to use it, what tasks it tends to over-scope or under-deliver on.

## Sanitization expectations

Everything under `agents/` is public-facing. Strip these before merging:

- Local filesystem paths (`/home/...`, `/Users/...`).
- Private project, client, or person names.
- Credentials, tokens, API keys, internal hostnames.
- References to private repos, org-internal services, or non-portable tooling.

If an agent is too tightly coupled to a private context to sanitize, leave it in `~/.claude/agents/` locally and skip the playbook copy.

## Adding an agent here

When an agent earns its place (used across two or more projects, produced consistently good output, materially better than doing the work in the orchestrator), drop the sanitized markdown file in here and add a row to `agents-index.md`. Keep both lists honest by only including agents that have proven themselves.

The `/nautilus-sync` skill automates the sanitize-and-copy step.

## Installing into `~/.claude/agents/`

User-level install via `install-tools.sh` at the repo root:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
```

That copies every agent file in this folder into `$HOME/.claude/agents/` so Claude Code auto-loads them. Pass `--agents name1,name2` to install a subset, `--no-overwrite` to refuse to clobber existing copies, or `--dest DIR` to target a non-default home.
