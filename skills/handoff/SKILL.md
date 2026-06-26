---
name: handoff
description: Capture the state of an in-flight session into HANDOFF.md so a future session, teammate, or agent can resume without re-deriving context. Complements /warmup. Use when pausing work, nearing context limits, changing hands, or ending a long session with open decisions.
---

# Session Handoff

Write a concise continuation packet for the next session. Git history explains what changed; `HANDOFF.md` explains what is still true, what is unresolved, and where to resume.

## When to invoke

- Pausing mid-task.
- Near context limit.
- Passing work to another developer or agent.
- Ending a long session with open decisions.
- After trying approaches that should not be repeated.
- Before switching repositories or priorities.

## When not to invoke

- Trivial sessions with no open state.
- Work fully committed, pushed, verified, and obvious from the commit message.
- Early brainstorming with no repo state to preserve.

## Process

### 1. Snapshot repository state

Use compact commands:

```bash
git rev-parse --short HEAD 2>/dev/null
git branch --show-current 2>/dev/null
git status --short
git stash list
git log --oneline -15
git diff --stat HEAD 2>/dev/null
git diff --stat --cached 2>/dev/null
```

Capture branch, HEAD SHA, working tree status, stashes, recent commits, staged/unstaged diff stats, and untracked files.

### 2. Read resume context

Read any present files:

- `implementation_plan.md`
- `repo_orientation.md`
- `HANDOFF.md`
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- recent ADRs under `docs/adr/` or `adr/`

Do not paste secrets, controlled data, raw environment values, customer names, or internal hostnames into the handoff.

### 3. Check lightweight gates

Use existing repo evidence only. Do not invent commands.

Capture commands and result summaries for relevant gates:

- test
- build
- lint/typecheck/format
- security scan
- release/deploy dry run

If no command is documented, write `Not documented`. If a command is too expensive or unsafe to run, write `Not run` and explain why.

### 4. Capture decisions and dead ends

Record:

- Decisions made this session and why.
- Open decisions or user input needed.
- Approaches tried and rejected.
- Files changed or created.
- Follow-up risks and cleanup needs.

This section is what prevents the next session from repeating old work.

## Output

Write or update `HANDOFF.md` at the repo root unless the user asks for chat-only output.

Use this structure:

```markdown
# Handoff — <branch> @ <short-sha>

> Generated: <YYYY-MM-DD HH:MM UTC>
> Stale when branch or HEAD changes from this value.

## Current State
- Branch:
- HEAD:
- Working tree:
- Stashes:

## What Changed
- <commits, files, or functional changes from this session>

## Mid-Flight Work
- <uncommitted files, incomplete tasks, scratch files, TODOs>

## Decisions Made
- <decision + rationale>

## Tried and Rejected
- <approach + why it failed or was rejected>

## Open Decisions
- Decide: <question> — current leaning: <option/reason>

## Validation State
| Gate | Status | Evidence |
|---|---|---|
| `<command>` | PASS / FAIL / NOT RUN / N/A | <short output or reason> |

## Files to Read First
- `path/to/file` — why it matters

## Resume Steps
1. Run `/warmup`.
2. Read `HANDOFF.md`.
3. <exact next action>

## Risks and Notes
- <security, data, deploy, test, or coordination risks>
```

## Existing handoff behavior

If `HANDOFF.md` already exists:

- Preserve useful previous context only if it still applies.
- Move stale content under `## Archived — <date>` or replace it with a short reference.
- Do not let `HANDOFF.md` grow into a transcript. Keep the current resume state first.

## Guardrails

- Keep it short and action-oriented.
- Do not dump transcripts or long logs.
- Do not expose secrets, controlled data, raw env values, customer names, or internal hostnames.
- Do not claim tests passed unless they were run.
- Use GitLab terminology for GitLab repos and GitHub terminology for GitHub repos.
- Make the first resume action concrete enough that a fresh session can start immediately.

## Companion skill

`/warmup` reads repo-local context at session start. `/handoff` writes resume context at session end. Best cycle:

```text
End session: /handoff
Resume later: /warmup, then read HANDOFF.md
```
