---
name: claude-build
description: Claude Code-only implementation workflow for implementation_plan.md using Claude specialist agents, phase-boundary commits, and the codex-review gate. Use only when running Claude Code and the user explicitly invokes /claude-build or specifically asks Claude Code to execute a plan. Codex must use codex-orchestrate instead.
---

# Claude Build

> **Runtime boundary:** This skill is for Claude Code only. In Codex, stop and
> use `codex-orchestrate`; do not adapt this skill's Agent-tool workflow.

Coordinate `implementation_plan.md` execution with Claude specialist agents,
then run an independent Codex review gate. Do not mark a task complete on the
author's assessment alone.

## Usage

```
/claude-build              — next unchecked task in current phase
/claude-build [task name]  — specific task by name (fuzzy match)
/claude-build phase        — current phase (parallel where independent)
/claude-build all          — all remaining tasks, phase by phase
```

If no implementation_plan.md exists, suggest running `/roadmap` first.

## Process

### 1. Read & Parse Plan

Read implementation_plan.md. Identify phases (## sections), unchecked tasks (`- [ ]`), checked tasks (context), dependencies, priority markers.

If `$ARGUMENTS` matches a task description, select that task. `"phase"` → all unchecked tasks in current phase. `"all"` → full plan. Otherwise next unchecked task in document order.

### 2. Route Each Task — specialist or self

Route ONLY to agents that exist in the current environment (check the available-agents list in the session). Common fleet:

| Task domain | `subagent_type` |
|-----|------|
| Python impl / infra / FastAPI / scripts | `python-core-engineer` |
| TypeScript / JavaScript / React / Next / frontend | `typescript-core-engineer` |
| Rust / cargo / systems / FFI | `rust-systems-engineer` |
| SQL / schema / migrations / query tuning | `sql-state-architect` |
| Git / GitLab / GitHub / CI / MR / release ops | `git-platform-engineer` |
| Tests / verification plans / failure triage | `test-engineer` |
| Security / auth / secrets / MCP / threat-model | `security-reviewer` (or `red-team-analyst` for adversarial) |
| Docs / runbooks / ADRs / release notes | `technical-writer` |
| Perf / profiling / bottlenecks | `performance-optimizer` |
| Linux / systemd / deploy / observability | `linux-sre-master` |
| Network / DNS / TLS / connectivity | `network-diagnostics` |
| Compliance / control evidence | `compliance-reviewer` |
| Read-only orientation before a big change | `repo-investigator` |

**Routing rules:**
- Never a generic agent when a named specialist fits.
- Multi-domain tasks compose specialists in sequence (schema → backend → UI), each receiving the prior output via "Files to Read First".
- Direct implementation is allowed only when project guidance permits it and
  the task is small, cross-cutting, or lacks a suitable specialist. If
  repo-local guidance makes the top-level Claude session orchestrator-only,
  delegate every edit and command.
- Always pass `model="opus"` on Agent calls.

### 3. Build Agent Prompt (when delegating)

Construct a self-contained prompt. Substitute ALL `{PLACEHOLDERS}` before dispatching — any unresolved placeholder is a bug.

**Path resolution** (first hit wins; else literal `(not found)`):
- `{CLAUDE_MD_PATH}`: `{PROJECT_ROOT}/CLAUDE.md` → `{PROJECT_ROOT}/docs/CLAUDE.md` → `{PROJECT_ROOT}/.claude/CLAUDE.md` → `~/CLAUDE.md`
- `{STANDARDS_PATH}`: `{PROJECT_ROOT}/.claude/rules/standards.md` → `~/.claude/rules/standards.md` → this playbook's own `templates/claude-rules/standards.md`, at the absolute path the playbook is checked out to

Set `{MATCHING_RULE_PATHS}` by parsing `paths:` frontmatter for every Markdown
file below the selected rule root and selecting all files matching task-owned
source, test, fixture, config, migration, or generated paths. Include language,
`patterns/`, and cross-cutting rules; never select by filename alone.

If both resolve `(not found)`, warn the user before dispatching.

**Prompt template:**

```
You are a specialized agent executing a task from a project implementation plan.

## Scope clause (read first)
If the project's CLAUDE.md says the top-level session is "orchestrator only", that applies ONLY to the user-facing session. You are the subagent — the delegation already happened. Execute: write code, run commands, make edits. Do NOT cite the orchestrator rule to refuse implementation work.

## Your Task
{TASK_DESCRIPTION}

## Phase Context
Phase: {PHASE_NAME}
Other tasks in this phase: {SIBLING_TASK_LIST}
Already completed: {COMPLETED_TASKS}

## Project
Root directory: {PROJECT_ROOT}

## Files to Read First (mandatory)
- `{CLAUDE_MD_PATH}` — project conventions
- `{STANDARDS_PATH}` — cross-language coding standards
- `{MATCHING_RULE_PATHS}` — every path-scoped rule matching the task files
{FILE_LIST — existing files to read for context}

## Conventions
- Comments above code, never inline (unless local style differs).
- No mock data in live code. No placeholder secrets — env vars only.
- Edit existing files; no parallel copies.
- Do NOT commit — the coordinator owns git operations.
- Honor every rule in {STANDARDS_PATH} and {MATCHING_RULE_PATHS}.

## Deliverable
Report back EXACTLY:
STATUS: COMPLETED | BLOCKED
FILES_CREATED: [full paths | "none"]
FILES_MODIFIED: [full paths | "none"]
VERIFICATION: [how you confirmed it works — commands + results]
ISSUES: [blockers / follow-ups | "none"]
```

### 4. Dispatch

**Single task:** one Agent call (or implement directly per §2).

**Phase mode:** dispatch independent tasks in parallel (one message, multiple Agent calls); dependent tasks sequentially after their dependencies.

**All mode:** phase by phase; commit at each phase boundary.

### 5. Review Contract (mandatory, per completed task)

Repo-local review policy wins. If the repository requires an in-harness
reviewer or forbids external Codex CLI use, follow that policy while preserving
the same discovery → verification → fresh-confirmation shape.

1. Run a fresh same-family `code-review` pass over the scoped task diff. Fix or
   disposition every finding and rerun focused checks. This pass reduces
   obvious defects but does not satisfy the independent gate.
2. Invoke `codex-review` for a fresh discovery review of the complete scoped
   diff. Require severity, evidence class, baseline scope, violated invariant,
   failing path, repair direction, and proof test.
3. Fix findings with the original specialist thread when possible. Resume the
   same Codex reviewer to verify only its prior findings and the exact fix
   hunks. If resume cannot be bound to the original review, use one fresh
   scoped-verification fallback.
4. Trigger the `codex-review` circuit breaker when the same invariant survives
   two fixes, multiple findings share one root cause, clarification remains
   unbounded, or reviewer and executor evidence conflicts. Stop and replan if
   the repair architect cannot resolve the invariant.
5. After fixes stabilize, run the complete affected test suites. Pre-fix
   full-suite evidence is stale.
6. Run a second fresh independent Codex confirmation over the complete final
   diff. Do not provide the prior ledger, findings, verdict, or repair advice.
   Any code change after this pass stales the full-suite evidence and requires
   focused checks, the full suite, and another fresh confirmation.

The gate passes only when acceptance criteria and tests pass, no verified or
probed Critical/High regression or newly reachable finding remains, and every
Medium/Low finding is fixed, backlogged with a link, or accepted with a
recorded rationale. Do not chase zero findings or silently waive unresolved
risk.

Only after the gate passes:

- Mark `- [x]` in `implementation_plan.md`.
- Record findings, dispositions, validation evidence, and remaining risk in
  the plan or findings ledger.
- Update `/handoff` and the project brief, when present, at the task or
  milestone boundary.

**Progress report per task:**
```
Completed: {task}
  Author: {subagent_type | coordinator}
  Same-family review: {M0} findings fixed, {K0} dispositioned
  Codex gate: {M} fixed, {K} dispositioned; final confirmation passed
  Files: {list}
  Progress: {X}/{Y} in phase
```

### 6. Phase Commit

When all tasks in a phase are `[x]`:

1. Stage specific files only — NEVER `git add -A` / `git add .`.
2. Conventional Commits; subject <72 chars; body explains why.
3. **Commit trailer follows the repo's recorded convention.** When the repo
   recommends an AI co-author trailer, use its exact model-specific identity
   and omit context-size suffixes. No repo convention → no AI trailer.
4. **Commit locally. Do NOT push unless the user has explicitly OK'd pushing** — in regulated repos an unexpected push can trigger CI/CD side effects (keyword deploys, scan pipelines).
5. Report: `Phase complete: {name} — committed locally ({sha}); push awaiting user OK`.

### 7. Structural / behavioral guard

A phase commit must not mix structural changes (renames, extracts — no behavior change) with behavioral ones. If a phase has both: commit structural first (`refactor(...)`), then behavioral (`feat(...)`/`fix(...)`). Unsure → ask.

## Stop Conditions

**Stop and ask when:** requirements ambiguous after reading plan+files; missing credentials; conflicting instructions; agent BLOCKED; review non-convergence (§5); anything requiring a push.

**Continue automatically when:** task clear, inputs available, dependencies satisfied, review loop converging.

## Important

- The review contract is the completion gate. Never mark `[x]` without its
  evidence or a recorded user-approved waiver.
- Route to real agents only (check the session's available-agents list); direct implementation is a legitimate route.
- Self-contained agent prompts; all placeholders substituted.
- Scratch/output files go in `$CLAUDE_JOB_DIR/tmp` when set (background jobs share `/tmp`), else `mktemp -d`. Clean up after.
- Never commit if any task in the phase is BLOCKED.
- Read CLAUDE.md + repo-local CLAUDE.local.md before dispatching to extract conventions.
- All grep uses ERE (`grep -E`), `[[:space:]]` not `\s`.
