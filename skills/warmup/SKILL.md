---
name: warmup
description: Warm up a fresh Claude/Codex session by loading repo-local context. Use when starting work in an existing repo, "warm up", "get context", "catch up", "load project", or "what have we been working on". Summarizes rules, recent git history, current state, and likely next steps.
---

# Session Warmup

Quickly load enough repository context to work safely without rereading the whole repo. Keep output concise: orientation, current state, risks, and next actions.

## When to invoke

Use at the start of a fresh session, after switching repositories, after context compaction, before planning work in an unfamiliar repo, or before resuming a paused implementation.

## Process

### 1. Read repo-local instructions

Read any present files:

- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `codingStandards.md`
- `.claude/`
- `docs/`

Repo-local instructions override global defaults. Do not paste secrets or controlled data from these files into the summary.

### 2. Read handoff and plan docs

Read any present files:

- `HANDOFF.md`
- `handoff.md`
- `implementation_plan.md`
- `repo_orientation.md`
- `CHANGELOG.md`
- recent ADRs under `docs/adr/` or `adr/`

Capture current resume point, blockers, open decisions, and planned next task.

### 3. Inspect recent history and state

Use compact commands:

```bash
git branch --show-current
git status --short
git log --oneline --stat -15
git stash list
```

If the repo is GitLab-hosted, use merge request/pipeline terminology. If GitHub-hosted, use pull request/Actions terminology. If unknown, use platform-neutral language.

### 4. Identify repo shape

Briefly identify:

- main language/framework/runtime
- package/build files
- test commands if documented
- CI/CD platform
- deploy/runtime hints
- sensitive-data or compliance-relevant areas

Do not run installs, tests, builds, network calls, or write files during warmup unless the user explicitly asks.

## Output

Return this structure:

```markdown
## Session Context Loaded

**Project:** <name or directory>
**Branch:** <branch>
**Status:** clean / uncommitted changes / stashed work / unknown
**Platform:** GitLab / GitHub / other / unknown

### Repo Rules
- <key repo-local rules>

### Recent Activity
- <theme from recent commits>
- <files or areas touched>

### Current Work Surface
- <likely active task or area>
- <relevant docs/plans/handoff notes>

### Commands Found
- Setup: <command or Not documented>
- Test: <command or Not documented>
- Build: <command or Not documented>
- Deploy: <command or Not documented>

### Risks / Gaps
- <uncommitted changes, missing docs, unclear deploy path, sensitive data, failing tests, etc.>

### Ready Next
- <1-3 concrete next actions>
```

## Guardrails

- Evidence first. Do not invent commands, deployment paths, or project purpose.
- Keep summary short enough to be useful in the main context.
- Flag uncommitted changes and stash entries.
- Do not expose secrets, controlled data, customer names, internal hostnames, or raw environment values.
- Do not modify files during warmup.
- If repo instructions conflict, report the conflict and follow the most local file.
