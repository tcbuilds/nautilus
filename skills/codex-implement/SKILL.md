---
name: codex-implement
description: Delegate an implementation slice or review-directed repair to the Codex CLI (Luna, xhigh effort) while Claude stays orchestrator. Use when the user wants cross-family implementation, Codex writes the code, or Claude must turn a Sol review or Sol-max repair contract into a bounded Luna fix.
---

# Codex Implement

Claude designs, briefs, verifies, and owns Git. Luna implements. Sol gates via `codex-review`; author and gate reviewer must differ.

## Profiles

Install without overwriting existing profiles:

- `assets/luna_xhigh_executor.config.toml` -> `${CODEX_HOME:-$HOME/.codex}/luna_xhigh_executor.config.toml`
- `assets/luna_high_executor.config.toml` -> `${CODEX_HOME:-$HOME/.codex}/luna_high_executor.config.toml`
- `assets/luna_max_executor.config.toml` -> `${CODEX_HOME:-$HOME/.codex}/luna_max_executor.config.toml`
- `assets/luna_max_brief_rescuer.config.toml` -> `${CODEX_HOME:-$HOME/.codex}/luna_max_brief_rescuer.config.toml`

Preflight the installed file, not `codex ... --help` (help does not load the profile): require the exact `${CODEX_HOME:-$HOME/.codex}/<name>.config.toml`, parse it with a local TOML parser, and assert expected model, effort, network, and delegation pins. Launch with `--strict-config` for Codex's recognized-key check. Executor pins `gpt-5.6-luna` xhigh. Optional brief rescuer pins Luna max and disables delegation. Review stays `gpt-5.6-sol` high.

Xhigh is the executor default. A slice brief carries a design that already resolved the reasoning, so the tier buys fidelity on a long contract rather than fresh analysis — and xhigh holds a long contract without max's wall-clock cost.

Three executor profiles stay installed, differing ONLY in `model_reasoning_effort`: `luna_high_executor`, `luna_xhigh_executor`, `luna_max_executor`. Change tier by switching the `-p` name, never by editing a profile in place — the launch line is then self-documenting about which tier ran, which is what makes two slices comparable after the fact. Reserve `luna_max_executor` for a slice whose brief is long AND whose invariants are cross-cutting; prefer `codex-review`'s Sol-max repair architect over a max executor when the problem is diagnosis rather than transcription.

Profiles carry no `name` or `description` key. Codex rejects both as unknown configuration fields under `--strict-config`; the description lives in a leading `#` comment instead.

## Track work

Create one harness task per plan slice, in plan order. Keep it `pending` until launch, `in_progress` through fixes, and `completed` only after gate closure, plan update, and any accepted-risk disposition.

## Parallelize implementation aggressively

**Default to many concurrent Luna lanes, not one big brief.** Luna is cheap; the scarce resources are wall-clock and the coordinator's attention. A serial lane that could have been four is waste. This applies to IMPLEMENTATION only — reviews stay single-gate and serial, because a gate's value comes from one reviewer holding the whole diff.

Batching everything into one brief has a specific failure mode: when the hardest item comes back BLOCKED or wrong, its fix round drags every other item's context along with it. One session, one report, one resume thread, one entangled retry.

### Split by risk, never by count

1. **Each cross-cutting or design-bearing item gets its own lane.** These are the ones that come back BLOCKED, need a clarification, or get the design subtly wrong. Isolate them so their fix round costs only themselves.
2. **Small mechanical items batch into one lane.** Four one-line guards do not need four sessions; the per-lane overhead would exceed the work.
3. **Items sharing a FILE stay in the same lane. Always.** Check file overlap before counting lanes — two findings in one file cannot be split apart, so a five-finding round may only afford three or four lanes.

### What parallelism costs, so the split is deliberate

- **Standards context multiplies per lane.** Every brief must name the rule files by absolute path (see "Standards reach Luna only through the brief"), so each lane re-reads them. Accept this — Luna is cheap and a style violation caught at the gate costs a whole round.
- **Concurrent lanes in ONE worktree collide** on Git state, a shared `.venv`, and pytest cache artifacts. Either partition the editable file set strictly per lane and name every file another lane holds, or give each lane its own worktree. Strict partitioning is usually enough and much cheaper than N worktrees.
- **Round-0 surface grows with lanes.** N lanes means N diffs to review and N reports whose claimed counts you must re-run independently. Budget for it.

### Rules that do not relax under parallelism

- One harness task per lane, so a later comparison knows what ran where.
- Every lane gets its own CLOSED editable file set. An implicit set plus concurrency produces conflicting edits to the same file.
- No lane commits. The coordinator integrates and owns Git, exactly as serial.
- Verify each lane independently. Never let one lane's green suite stand in for another's.

## Launch

```bash
OUT=<scratch>/codex-luna-<slice>.md
cd <worktree-or-repo-root>
rtk proxy timeout 3500 codex exec -p luna_xhigh_executor --strict-config \
  --add-dir "$HOME/.local/share/rtk" --skip-git-repo-check \
  --output-schema "<skill-dir>/assets/implement-result.schema.json" \
  -o "$OUT" '<BRIEF>' < /dev/null
```

Run in background; foreground harness calls can kill long runs. Profile enables workspace-write network access for all hosts. Required guards:

- Keep `rtk proxy` when available, `< /dev/null`, and bounded `timeout`.
- Missing/empty `$OUT` or nonzero exit = failed run. Inspect Git before judging whether edits landed.
- Never trust report paths or claimed checks without independent verification.

### Variables

Resolve all of these to absolute paths before the launch line runs. Nothing here is a literal.

| Placeholder | Meaning |
|---|---|
| `<scratch>` | Writable scratch directory OUTSIDE the repo, so run artifacts never appear in `git status`. |
| `<slice>` | Short slug for this slice or lane, unique per concurrent run, so two lanes never share an `$OUT`. |
| `$OUT` | Absolute path where the executor's final schema-conformant message is written. One per lane. |
| `$RESCUE_OUT` | Same, for a brief-rescue run. Keep it distinct from every `$OUT`. |
| `<worktree-or-repo-root>` | Absolute path to the repo root or the lane's dedicated worktree. Codex resolves relative paths against it. |
| `<skill-dir>` | Absolute path to this skill's directory, the one holding `assets/`. |
| `<codex-review-skill-dir>` | Absolute path to the installed `codex-review` skill directory, for its `assets/fix-architecture-result.schema.json`. |
| `<BRIEF>` | The full brief text from "Brief contract", passed as one single-quoted argument. |
| `<packet-path>` | Absolute path to the file holding the verified repair contract plus the current seam summary, for a brief rescue. |

## Preflight

1. Read repo rules and trace exact touched symbols/files with CodeGraph first when indexed; otherwise inspect source directly. Cite hook points and hazards in brief.
2. Check target lint config enables relevant rule classes.
3. For external tools, require mock tests plus real-tool end-to-end tests that skip only when tool is absent.
4. For heuristics, matching, resolution, or inference, define evidence required for every acceptance path. Missing evidence fails closed. Tests must cite the requirement they encode.

### Design gate

When task says `Design gate: yes`, or uses heuristic resolution/inference:

1. Write a short contract covering acceptance paths, evidence, fail-closed and degradation behavior, budgets, and preparation mechanics.
2. If work prepares multiple inputs, queues/attaches jobs, or reads shared mutable state, include races and dedup/coalescing keys.
3. Run one Sol review over contract plus seam files: ask which inputs create wrong-but-confident output and which evidence class is missing.
4. Resolve findings before briefing Luna.

## Brief contract

Cold-start brief, in this order:

1. Mandatory read-first files, as ABSOLUTE paths you verified exist before briefing: `CLAUDE.md`, the coding standards, the matching `<language>-patterns.md`, the repo's test conventions, and named source/tests. Require declared justification for any deviation. See "Standards reach Luna only through the brief" below — this item is load-bearing, not boilerplate.
2. Exact CodeGraph query when `.codegraph/` exists.
3. Decided behavior: module placement, config conventions, failure semantics, and streaming behavior. Every judgment call already resolved — see "Resolve every subjective call before briefing" below. Luna implements; Claude designs.
4. Surgical scope as a CLOSED file set — "these files and no others" — plus do-not-touch files, file-format quirks, and no commit/push. Require BLOCKED with a reason rather than silent expansion. An implicit file set reads as permission: a brief that lists files only under "read first" will get edits outside them, and the expansion is usually justified, which means the brief was under-specified rather than the executor wrong. Name every file another concurrent run holds.
5. Named fixtures/tests mapping every DoD line to proof, each carrying the MUTATION that must break it. State it as acceptance: "revert X and this test MUST fail; paste the failure output." See "Demand mutation evidence" below — omit this and green runs come back as proof.
6. Exact focused test/lint/type commands and prior expected counts. Luna does not run full suite.
7. Final contract: run `git status --short` and `git diff --name-only`; return `assets/implement-result.schema.json`. `complete` requires a changed file. `no_change_needed` requires proof and explanation. Keep code, commands, test names, symbols, and exact errors verbatim.

### Resolve every subjective call before briefing

Claude owns every judgment call. Luna transcribes a resolved design; it does not choose between defensible options. A brief that says "put it wherever fits" or "use whatever field names make sense" has delegated design under the label of implementation, and the choice then surfaces at the review gate as a finding instead of at authoring time as a decision.

Before launch, walk the brief for anything the executor could reasonably answer two ways, and answer it yourself:

1. **Placement.** Name the seam — the function, the call site, the module. When a plan's stated seam turns out wrong, fix the plan; do not forward the contradiction. A plan that names a field list a seam cannot supply is a spec/reality mismatch: locate the seam that CAN supply it, brief that one, and say why the plan's seam was rejected.
2. **Exact strings and field names.** Log messages, metric names, config keys, enum values. Write them verbatim. Two runs picking two spellings for the same concept is a defect an operator finds in production, not in review.
3. **Every branch, including the boring one.** Flag off, empty input, feature disabled, nothing selected. State whether each path emits, and with what values. An unmentioned branch gets whatever the executor assumes.
4. **Known ambiguity you are ACCEPTING.** When two states are indistinguishable in the output and you judge that acceptable, say so, say why, and forbid the executor from inventing a field to fix it. Otherwise it will invent one, correctly, and outside scope.
5. **Trade-offs already lost.** When a cheaper approach was considered and rejected, name it and name the reason. Otherwise the executor re-derives it and picks it.

If a call is genuinely the user's — scope, risk appetite, a behavior change the plan does not authorize — stop and ask the user. Do not route a user-level decision to the executor either.

### Standards reach Luna only through the brief

Claude Code injects the coding standards and the matching `<language>-patterns.md` automatically, path-scoped, the moment a matching file is opened. **Codex has no equivalent.** It reads `AGENTS.md` / `AGENTS.local.md` at session start and nothing else. A rules POINTER inside `AGENTS.md` is not the rules CONTENT in context.

So an unnamed rule is an absent rule. Every standard the slice must honor — rule tiers, numeric limits, naming, comment placement, quality gates — reaches the executor only because the brief names the file by absolute path and requires reading it. Omit it and Luna writes reasonable code that violates house style, and the violation surfaces at the review gate instead of at authoring time, where it costs a fix round rather than nothing.

Resolve the paths per launch; do not hardcode them:

1. Prefer the repo copy: `<repo>/.claude/rules/coding-standards.md`. Fall back to `~/.claude/rules/coding-standards.md`. Fall back last to this playbook's own `templates/codingStandards.md`, at the absolute path the playbook is checked out to. Same cascade for `<language>-patterns.md`, `testing.md`, and `mcp-hardening.md` when the slice touches an MCP surface; the playbook's per-language files live under `templates/language-rules/`.
2. **Verify each resolved path exists before briefing.** A repo copy can be absent on the CHECKED-OUT branch while present on another — rule files often arrive on the very feature branch that adds them, so a worktree cut from an older base legitimately lacks them. Confirm with `git ls-tree --name-only <branch> .claude/rules/` when a path is missing rather than assuming a broken checkout.
3. Cite a path that does not resolve and the executor silently proceeds without that standard. Nothing errors. The brief looks complete.
4. **When no rung of the cascade resolves, do not cite a path anyway.** Drop the standards-citation requirement for that rule class, say so explicitly in the brief ("no coding-standards file resolved on this machine; house style is not available to you — follow the idiom of the files you edit and declare any judgment call"), and record the same fact on the harness task. A missing standard you named is recoverable at round 0; a fabricated path is silent.

State the effort tier and the resolved rule paths in the harness task, so a later comparison between slices knows what each run actually had.

### Demand mutation evidence, not passing runs

An executor reports a green suite as proof that its new test works. It is not. This is the costliest failure mode in the loop because it survives every later round: a test that cannot fail is a permanent hole that reads as coverage, and each gate sees it pass.

Observed twice in one slice: a test called `task.cancel()` on the line after `asyncio.create_task(...)` with no await between, so the coroutine body never ran and every assertion merely re-read state the test itself had assigned. It still passed with `raise AssertionError` inserted as the first statement of the function under test.

So put the acceptance in the brief, per test:

1. Name the exact mutation — one reverted thing, never a rewrite.
2. Name the test that must fail under it.
3. Require the failure output pasted verbatim.
4. Require a plain statement when a test will NOT fail under its mutation, instead of reporting it as proof.

Then rerun every mutation yourself. Reasoning about which test covers a mutation gives wrong answers, and each one costs roughly thirty seconds. Anchor each patch on a string that occurs exactly once and assert that count, or the patch silently applies nowhere and the test's pass proves nothing.

## Verify and review

1. Read `$OUT` tail. Derive change set using `git status --short`, `git diff --name-only`, and `git diff --stat`; record report mismatches.
2. Independently run focused tests, lint, and typecheck. Rerun every mutation the executor claimed; a claimed mutation is not evidence until you watch it fail.
3. Perform Claude round-0 hunk review, including the standards pass below.
4. Start fresh Sol `codex-review`.
5. Send fixes to original Luna session with `codex exec resume <session_id>`. For substantial fixes, re-pass `-m gpt-5.6-luna`, `-c model_reasoning_effort=xhigh`, and `--output-schema "<skill-dir>/assets/implement-result.schema.json"`. `resume` inherits sandbox/network and has no `--sandbox`, `--add-dir`, or `-p` flag at all — passing any of them is an argument error, so drop them on resume. Confirmed against codex-cli 0.146.0; re-check `codex exec resume --help` before removing any other flag.
6. After each fix, run affected checks and resume original Sol reviewer to verify only its findings.
7. When stable, run full affected suite once, then a second complete review in fresh Sol without prior findings/verdict. Compare ledger afterward.
8. Any later code change makes full-suite evidence stale. Re-run affected checks, full suite, and fresh Sol gate.

### Round-0 standards pass

Cheap conformance check on the diff hunks, every run. Lint and typecheck catch mechanics; this catches what they cannot express — house style and the rules the brief named. Read the diff, not the report.

Deliberately quick. Scope it to the hunks; do not re-review unchanged code.

Check:

1. The rule files the brief named were actually honored — numeric limits (file and function length), naming, comment placement, error handling shape, logging conventions. Skim the rule file again if the diff is large.
2. Comments explain WHY and sit above their code. No inline comments unless the surrounding file already uses them.
3. No mock data, placeholder secret, hardcoded path, or debug leftover in live code.
4. New code matches the idiom of the file it lands in — the local abstraction, not a parallel one. A second helper doing what an existing helper does is the common miss.
5. Test names state the behavior under test. Assertions target behavior, not implementation detail. Then hunt vacuity — a test that cannot fail: a task cancelled before its first await, an event set but never awaited, an assertion on state the test itself assigned, a `getattr(mod, "NAME", default)` whose default masks a rename, a probe anchored on a string that occurs twice. Cheapest detector: insert `raise AssertionError` as the first statement of the function under test and rerun. A still-passing test proves nothing.
6. No scope drift: every hunk traces to a brief line.

Disposition, in proportion:

- Trivial and mechanical (a comment placement, a name) — fix it yourself and move on. Cheaper than a fix round.
- Real but minor — note it for the Sol gate to weigh; do not spend a round.
- Blocking only when the code is genuinely bad: a violated hard rule, a wrong abstraction that will spread, or a test that cannot fail. Send those to the Luna session as a fix round, not to the reviewer.

Record the outcome against the effort tier that produced it, next to the tier and rule paths already noted on the harness task. Tier quality is an empirical question, and one line per slice is what makes it answerable later.

### Repair contract

When `codex-review` returns a Sol-max contract:

1. Validate `<codex-review-skill-dir>/assets/fix-architecture-result.schema.json`.
2. Verify every seam, path, symbol, and assumption against current CodeGraph and diff.
3. Resolve repo-rule/acceptance conflicts; stop for unauthorized behavior or scope changes.
4. Convert verified contract into normal Luna brief, including prohibited partial fixes and named regressions.
5. Resume original Luna, derive actual Git diff, run focused checks, then resume original Sol-high reviewer.

Sol-high supplies repair direction. Sol-max supplies root-cause design after circuit breaker. Neither writes executor brief or owns gate.

### Optional Luna-max brief rescue

Use once per finding family only when a valid architect contract remains ambiguous because of cross-cutting constraints, stale state, or seam ownership. Never use for routine formatting or as second architect.

```bash
rtk proxy timeout 1200 codex exec -p luna_max_brief_rescuer --strict-config \
  --add-dir "$HOME/.local/share/rtk" --skip-git-repo-check \
  --output-schema "<skill-dir>/assets/brief-rescue-result.schema.json" \
  -o "$RESCUE_OUT" \
  "Read the verified repair contract and current seam summary at <packet-path>. Draft a bounded Luna executor brief. Do not edit files, implement, review, delegate, commit, or push." \
  < /dev/null
```

Run in background. Compare Git status/diff names before and after. Claude verifies/finalizes draft. If blocked, stop and replan or ask user. Never expose architect output, rescue output, ledger, or prior verdicts to fresh final Sol.

## Stop and checkpoint

Stop when all acceptance tests and full suites pass, no empirically verified or probed Critical/High remains, and every Medium/Low is fixed, backlogged with a link, or accepted with rationale. Do not chase a zero-finding stamp.

After commit:

1. Tick plan and complete matching harness task; record accepted risks.
2. Update `HANDOFF.md`.
3. Save next Luna brief while context is hot.
4. Run `/clear`, not `/compact`.
5. Next session: `/warmup` resume mode, then launch saved brief.

Never clear/compact mid-loop.

## Gate rules

- Implementer never gate-reviews own work.
- Commit only after final full-suite evidence and fresh review pass.
- MR evidence: DoD -> named tests, exact independent commands/counts, rollback, and changed-symbol blast radius. Do not include agent/model/round mechanics, internal plans/handoffs/briefs, or formal residual-risk ceremony.
- Cost source: cumulative `total_token_usage` in `~/.codex/sessions/**/*.jsonl`.
- Never put secrets or controlled data in briefs; refer to secret names only.
