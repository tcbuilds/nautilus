# Phase 5 — Maintaining the Playbook

The playbook is a living asset. As skills and agents mature through real project use, the playbook should reflect what actually works — not what was speculated up front.

## How sync works

Source of truth is the local Claude Code config directory:

- Skills live in `<claude-config>/skills/<name>/SKILL.md`
- Agents live in `<claude-config>/agents/<name>.md`

The nautilus repo is downstream prose: per-skill and per-agent docs in `skills/` and `agents/`, plus rows in `skills-index.md` and `agents-index.md`.

When a skill or agent earns its place — used across two or more projects, output reliable enough to vouch for publicly — promote it into the playbook with the `/nautilus-sync` skill.

## The `/nautilus-sync` skill

```
/nautilus-sync skill <name>
/nautilus-sync agent <name>
```

What it does, in order:

1. Reads the source from `<claude-config>/skills/<name>/SKILL.md` or `<claude-config>/agents/<name>.md`.
2. Pipes the source through a deterministic sanitizer that strips identity strings, hardcoded paths, embedded API keys, exchange/protocol names, project codenames, and incidental trading-domain framing.
3. Reframes the sanitized content into the playbook's per-entry format (When / What / Examples / Gotchas for skills; What it's for / When to delegate / Examples / Anti-patterns for agents).
4. Writes the new doc to `nautilus/skills/<name>.md` or `nautilus/agents/<name>.md`. Warns on >50% size deltas.
5. Appends a row to the matching index file if not already present.
6. Prints a substitution summary: how many path refs, identity strings, API keys, and codenames were stripped.

The skill does not commit. Review the diff, then commit and push manually.

## When to invoke

- After a skill or agent has been used on at least two distinct projects with consistent results.
- After meaningfully upgrading the source SKILL.md or agent definition in local config.
- After discovering a sanitization gap that the regex pass should have caught — patch the sanitizer, then re-sync everything affected.

## When not to invoke

- For skills or agents that are inherently private (pull private transcripts, hardcode one person's services, or depend on confidential context). These do not get sanitized — they get excluded.
- Before the entry has earned its place. The point of the playbook is signal, not exhaustive coverage. If something hasn't proven itself, leave it out.

## Sanitizer scope

The sanitizer covers recurring leakage patterns observed across local skills and agents:

- Home-directory paths -> `<home>/`
- Identity strings (GitHub user, email, org names) → placeholders
- Embedded API keys and bare hex strings ≥32 chars → `<redacted-...>`
- Named exchanges, protocols, project codenames → generic placeholders
- `readme-status-badges` trailer blocks (the auto-generated python invocations)
- Incidental trading-domain framing (only softened when the entry isn't genuinely trading-domain — the sanitizer detects this and leaves real domain framing intact)

The regex table lives with the sanitizer implementation. Add new patterns there as new leakage vectors emerge.

## Lifecycle in one sentence

Mature the source locally, sync downstream into nautilus when the entry is ready, review the diff, commit and push.
