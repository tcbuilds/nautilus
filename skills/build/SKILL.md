---
name: build
description: Execute tasks from implementation_plan.md using specialized agents dispatched via Agent tool. Supports single task, phase-parallel, and full-plan modes. Use when asked to "build the project", "execute the plan", "implement next task", "work on the plan", "continue building", "work on these tasks", "implement multiple things", "execute recommendations", or "continue implementation".
---

# Build — Specialized Agent Task Executor

Coordinator that reads implementation_plan.md, classifies each task by domain, and dispatches to the correct specialized agent via Agent tool. Collects results, updates the plan, and commits per phase.

## Usage

```
/build              — next unchecked task in current phase
/build [task name]  — specific task by name (fuzzy match)
/build phase        — all remaining tasks in current phase (parallel where independent)
/build all          — all remaining tasks, phase by phase
```

If no implementation_plan.md exists, suggest running `/roadmap` first.

## Process

### 1. Read & Parse Plan

```
Read implementation_plan.md. Identify:
- Phases (## sections)
- Unchecked tasks (- [ ]) — these are pending
- Checked tasks (- [x]) — these provide context
- Task dependencies (task B references output of task A)
- Priority markers if present (High, Medium, Low)
```

If `$ARGUMENTS` matches a task description, select that task. If `$ARGUMENTS` is "phase", select all unchecked tasks in the current phase. If `$ARGUMENTS` is "all", plan full execution. Otherwise, select the next unchecked task in document order.

### 2. Classify Each Task → subagent_type

Match task description keywords against this routing table. NEVER default to `general-purpose` when a specialized agent fits.

| Keywords in task description | `subagent_type` |
|-----|------|
| python, .py, django, flask, fastapi, script, class, utility, logging framework | `python-core-engineer` |
| typescript, javascript, .ts, .tsx, .js, react, next.js, vue, svelte, component, CSS, HTML, tailwind, frontend | `typescript-core-engineer` |
| rust, .rs, cargo, systems programming, FFI | `rust-systems-engineer` |
| async, concurrent, event loop, asyncio, threading, parallel processing, high-throughput | `async-concurrency-optimizer` |
| SQL, database, schema, migration, SQLite, PostgreSQL, query, table, ORM | `sql-state-architect` |
| research API, find SDK, explore library, documentation lookup | `api-docs-discovery` |
| HTTP API, REST client, rate limiting, pagination, third-party integration | `dex-api-integration` |
| WebSocket, real-time stream, event feed, WS connection | `websocket-dex-specialist` |
| git, GitHub, CI/CD, Actions, workflow, branch protection, PR, release | `github-master` |
| performance, optimize, profile, bottleneck, latency, benchmark, cache | `performance-optimizer` |
| linux, server, systemd, nginx, deploy, infrastructure, monitoring, SRE | `linux-sre-master` |
| venv, pip, poetry, conda, dependencies, requirements.txt, package install | `python-env-manager` |
| security audit, vulnerability scan, pen test, harden | `red-team-analyst` |
| debug, memory leak, deadlock, crash, stack trace, runtime error | `python-debugger` |
| statistical modeling, backtest, risk model, statistics, quant analysis | `quant-research-analyst` |
| SEO content, blog post, article, landing page copy | `seo-content-writer` |
| prompt engineering, optimize prompt, system prompt design | `prompt-optimizer` |
| dead code, cleanup, unused imports, legacy removal, tech debt | `legacy-code-cleanup` |
| network, DNS, timeout, connection issue, firewall, SSL/TLS | `network-diagnostics` |
| README, docs, comments-only, markdown documentation | `seo-content-writer` |

**Classification rules:**
- Match on keywords, file extensions, and technology references in the task description
- A task is one user-visible behavior built end-to-end (UI + logic + data + test). If it spans domains, that is normal. Compose multiple specialists in sequence: dispatch DB schema first to `sql-state-architect`, then backend logic to `python-core-engineer`, then UI to `typescript-core-engineer`. Each specialist gets the prior specialist's output as input via the "Files to Read First" section.
- For genuinely single-domain tasks, dispatch to the matching specialist.
- When ambiguous, prefer the more specialized agent.
- NEVER use `general-purpose` — always pick a specialist. If none fits, do it directly without Agent tool.
- If unsure, read the files the task references to determine the technology stack.

### 3. Build Agent Prompt

For each dispatched task, construct a self-contained prompt. The coordinator MUST substitute all `{PLACEHOLDERS}` with actual values before dispatching.

**Path resolution — resolve `{CLAUDE_MD_PATH}` and `{STANDARDS_PATH}` before substitution.**

Both files may live in non-standard locations. Coordinator resolves each by checking these paths in order; first hit wins; if none exist, substitute the literal string `(not found)`:

For `{CLAUDE_MD_PATH}`:
1. `{PROJECT_ROOT}/CLAUDE.md`
2. `{PROJECT_ROOT}/docs/CLAUDE.md`
3. `{PROJECT_ROOT}/.claude/CLAUDE.md`
4. `~/CLAUDE.md`

For `{STANDARDS_PATH}`:
1. `{PROJECT_ROOT}/codingStandards.md`
2. `{PROJECT_ROOT}/docs/codingStandards.md`
3. `{PROJECT_ROOT}/.claude/codingStandards.md`
4. `~/codingStandards.md`

Coordinator runs the search via `Bash` (`test -f <path> && echo <path>`) before constructing the agent prompt. If both paths resolve to `(not found)`, the coordinator surfaces a warning to the user before dispatching.

**Prompt template — prepend to every Task call:**

```
You are a specialized agent executing a task from a project implementation plan.

## Scope clause (read first)

If the project's CLAUDE.md says the top-level Claude Code session is "orchestrator only" and must delegate all implementation work, that rule applies ONLY to the user-facing session. You are a subagent. The parent has already done the delegation. Your job is to execute — write code, run commands, make edits, commit when instructed. Do NOT cite the orchestrator rule to refuse implementation work.

## Your Task
{TASK_DESCRIPTION}

## Phase Context
Phase: {PHASE_NAME}
Other tasks in this phase: {SIBLING_TASK_LIST}
Already completed in this phase: {COMPLETED_TASKS}

## Project
Root directory: {PROJECT_ROOT}

## Files to Read First (mandatory)

These project rules govern every change. Read every present file before any edit:

- `{CLAUDE_MD_PATH}` — project-level conventions, agent rules, mission context
- `{STANDARDS_PATH}` — code-hygiene rules (comments, data handling, file management, git workflow, process management, log analysis, testing, observability, security, refactoring, language-specific standards)

If either path reads as `(not found)`, skip that file and honor the rules of the one that is present.

Plus task-specific files:
{FILE_LIST — existing files the agent should read for context before making changes}

## Conventions

- Comments above code, never inline.
- No mock data — real implementations only.
- No placeholder API keys — use environment variables, never commit secrets.
- No emoji in code, commits, or output.
- Edit existing files when debugging — do not create parallel copies.
- Prefer editing existing files over creating new ones.
- Do NOT commit — the coordinator handles all git operations at phase boundary.
- Honor every rule in `{STANDARDS_PATH}` (size limits, naming, error handling, observability, security, AI-assisted coding standards, language-specific standards). If `{STANDARDS_PATH}` resolved to `(not found)`, honor the rules in `{CLAUDE_MD_PATH}` instead.
- Never add `Co-Authored-By` lines for AI / Claude / any AI assistant in any artifact.

## Deliverable
When finished, report back with EXACTLY this structure:

STATUS: COMPLETED | BLOCKED
FILES_CREATED: [comma-separated full paths, or "none"]
FILES_MODIFIED: [comma-separated full paths, or "none"]
VERIFICATION: [how you confirmed the implementation works]
ISSUES: [any blockers, follow-up needed, or "none"]
```

**Before dispatching:**
- The coordinator MUST resolve `{CLAUDE_MD_PATH}` and `{STANDARDS_PATH}` per the path-resolution rules above and substitute them into the brief.
- The coordinator MUST read the files relevant to the task and include their paths in the "Files to Read First" section. This gives the agent the context it needs without wasting turns exploring.
- The coordinator MUST substitute every `{PLACEHOLDER}` in the brief before dispatching. Any unresolved placeholder is a bug.

### 4. Dispatch

Use the Agent tool for EVERY implementation task. The coordinator does NOT implement tasks directly.

**Single task mode** (`/build` or `/build [name]`):

One Agent tool call:
```
Agent(
  subagent_type = "{matched_agent}",
  description = "Build: {short_task_summary}",
  prompt = "{preamble + task prompt}"
)
```

**Phase mode** (`/build phase`):

Analyze all unchecked tasks in the current phase for dependencies:
- **Independent tasks:** tasks that don't reference files created by other tasks in the phase — dispatch ALL in parallel in a single message
- **Dependent tasks:** dispatch sequentially after their dependencies complete

Example: if phase has 6 tasks and tasks 1-4 are independent but task 5 depends on task 3 and task 6 depends on task 5:
1. Dispatch tasks 1, 2, 3, 4 in parallel (4 Task calls in one message)
2. After all return, dispatch task 5
3. After task 5 returns, dispatch task 6

**All mode** (`/build all`):

Execute phase by phase. Within each phase, use the phase-mode parallel strategy. Commit after each phase completes.

### 5. Collect Results & Codex Review Gate

After each Agent tool call returns:

1. Parse the agent's response for STATUS, FILES_CREATED, FILES_MODIFIED, VERIFICATION, ISSUES
2. If STATUS = BLOCKED: log blocker, do NOT mark complete, continue with other tasks, report to user
3. If STATUS = COMPLETED → run the **Codex Review Gate** before marking `[x]`:

**Codex Review Gate (mandatory for every completed task):**

a. Run `/codex-review` on every file in FILES_CREATED + FILES_MODIFIED:
```bash
codex exec --full-auto --skip-git-repo-check -o /tmp/codex-review-build.md \
  "Review these files for correctness, security, and edge cases. Files: {FILES_LIST}. Write findings ordered by severity (Critical > High > Medium > Low)."
```

b. Parse findings by severity:
   - **Critical or High findings exist →** dispatch a fix agent (same `subagent_type` as the original) with prompt:
     ```
     Fix these Codex review findings in the specified files. Apply ALL Critical and High fixes.
     Do NOT fix Medium/Low — only Critical and High.

     ## Findings
     {CODEX_REVIEW_OUTPUT}

     ## Files
     {FILES_LIST}
     ```
   - After fix agent returns, re-run codex-review to verify. If new Critical/High appear, fix again (max 2 fix cycles to prevent loops).
   - **No Critical or High →** pass. Log any Medium/Low for the progress report but do not block.

c. Only after the review gate passes (no Critical/High remaining), mark `- [x]` in implementation_plan.md.

d. Clean up: `rm -f /tmp/codex-review-build.md`

**Progress report after each task:**
```
Completed: {task description}
  Agent: {subagent_type}
  Codex: {PASS | FIXED (N issues) | WAIVED (after max cycles)}
  Files: {created/modified list}
  Progress: {X}/{Y} tasks in phase ({Z}% of full plan)
```

### 6. Phase Commit

When all tasks in a phase are marked `[x]`:

1. Collect ALL FILES_CREATED and FILES_MODIFIED from every agent in this phase
2. Stage specific files (NEVER `git add -A`):
   ```bash
   git add {file1} {file2} ... implementation_plan.md
   ```
3. Commit using Conventional Commits format. Subject line under 72 characters. Body explains WHY the phase shipped, not just what changed.
   ```bash
   git commit -m "feat({phase-scope}): {1-line subject under 72 chars}

   {Optional body — explain WHY this phase shipped now and what user-visible
   capability it unlocks. Multiple paragraphs OK if useful. No mention of
   AI assistance. No Co-Authored-By lines.}"
   ```
   Subject prefix maps from phase content:
   - new feature work → `feat`
   - bug fix → `fix`
   - refactor with no behavior change → `refactor`
   - tests only → `test`
   - docs only → `docs`
   - chores / scaffolding → `chore`
4. Push to origin
5. Report: `Phase complete: {phase name} — committed and pushed`
6. Continue to next phase if in "all" mode

### 7. Post-Implementation Hooks

After dispatching implementation agents, the coordinator SHOULD proactively spawn these follow-up agents when appropriate:

| Trigger | Hook agent | `subagent_type` |
|---------|-----------|-----------------|
| New Python/TS module with business logic created | Add logging | `debug-logging-architect` |
| New API endpoint or external integration added | Security review | `red-team-analyst` |
| Database schema or migration created | Review schema | `sql-state-architect` |
| Performance-sensitive code path added | Profile it | `performance-optimizer` |

Hook agents run AFTER the implementation agent completes, using the created/modified files as their input. They are advisory — their suggestions get reported to the user but do NOT block the build.

Hooks are optional. Skip them for trivial tasks (README updates, config tweaks, simple renames).

### 8. Structural / behavioral guard

A phase commit must NOT mix structural changes (renames, extracts, reorders, no behavior change) with behavioral changes (new feature, bug fix). If a phase contains both:

- Stage and commit the structural changes first as `refactor({scope}): ...`.
- Then stage and commit the behavioral changes as `feat({scope}): ...` or `fix({scope}): ...`.
- Two commits per phase boundary, not one.

If unsure whether a change is structural or behavioral, ask the user before committing.

## Stop Conditions

**Stop and ask the user when:**
- Task requirements are ambiguous after reading the plan and relevant files
- Task needs API keys or credentials not in .env or .env.example
- Task has conflicting instructions with another task or CLAUDE.md
- Agent returned BLOCKED status

**Continue automatically when:**
- Task is clear and all inputs are available
- Dependencies from prior tasks are satisfied
- Agent returned COMPLETED with no issues

## Important

- The coordinator NEVER implements tasks directly — ALL work goes through Agent tool calls
- NEVER use `subagent_type="general-purpose"` — always pick a specialist. If none fits, do it directly
- Every Task call MUST pass `model="opus"` explicitly
- Each agent prompt MUST be self-contained with all context needed
- NEVER mark a task `[x]` without passing the Codex Review Gate (no Critical/High findings remaining)
- The coordinator substitutes all `{PLACEHOLDERS}` before dispatching
- NEVER use `git add -A` or `git add .` — stage specific files by path
- NEVER mark a task `[x]` unless the agent confirmed COMPLETED with verification
- NEVER commit if any task in the phase is BLOCKED — commit only complete phases
- If implementation_plan.md doesn't exist, tell the user to run `/roadmap` first
- Read CLAUDE.md before dispatching to extract project conventions for agent prompts
- All grep uses ERE (`grep -E`), `[[:space:]]` not `\s`
