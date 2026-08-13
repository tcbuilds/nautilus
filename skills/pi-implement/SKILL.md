---
name: pi-implement
description: Execute one implementation slice or an implementation_plan.md task, phase, or full plan through Pi-native subagent workflows. Uses parent-owned design, one writer per worktree, managed isolation for safe parallel lanes, independent verification, and a pi-review gate. Use only when running Pi with pi-subagents.
compatibility: Requires Pi with pi-subagents 0.46.0 or newer and executable worker and reviewer agents.
---

# Pi Implement

Pi orchestrates, workers implement, and independent reviewers gate the integrated change. Do not shell out to Codex, Claude Code, or another agent CLI. Use Pi's `subagent` tool with `workflowScript` for every child launch.

## Usage

```text
/skill:pi-implement "<single task>"
/skill:pi-implement <brief-path>
/skill:pi-implement                 # next unchecked plan task
/skill:pi-implement phase           # current phase
/skill:pi-implement all             # remaining phases in order
```

For a standalone task, treat it as a one-slice phase. For plan work, read [plan orchestration](references/plan-orchestration.md) before launching writers. If neither a plan nor a task exists, ask what to implement.

## Runtime contract

Before execution:

1. Require `pi-subagents >=0.46.0`; if the installed version cannot be verified, report the unverified preflight rather than assuming retained-resume behavior.
2. Run `subagent({ action: "list" })` and use only executable, non-disabled agents.
3. Read repository instructions, the plan or brief, matching path-scoped rules, target source, and relevant tests. The parent personally verifies the load-bearing seams.
4. Resolve user-owned product, scope, risk, release, merge, and architecture decisions before implementation. Ask rather than delegating an unresolved decision.
5. Define a validation contract: expected behavior, focused checks, user-visible exercise where relevant, and evidence required from the writer.
6. Record the baseline ref, dirty paths, staged paths, and intended file ownership. Preserve unrelated work. If pre-existing staged paths exist, do not request whole-checkout `no-staged-files` evidence; isolate the writer or explicitly verify that it staged no additional paths.

The parent owns slicing, decisions, integration, validation, findings disposition, plan updates, and Git publication. Children do not launch subagents unless an explicitly configured fanout role is assigned that narrow job.

## Slice by ownership and risk

Default to one writer in the active worktree. Use parallel writers only when the work has genuinely independent file ownership and each writer receives `worktree: true`.

- Give each design-bearing or cross-cutting item its own slice.
- Batch small mechanical changes that share one seam.
- Any shared source, test, fixture, migration, manifest, lockfile, or generated output creates a dependency edge.
- Keep a closed editable path set per slice. Required work outside it means `BLOCKED`, not silent scope expansion.
- Cap a parallel wave at four lanes unless project policy sets a lower limit.
- Never run multiple writers in the same checkout.

## Brief contract

Give every worker a compact, self-contained contract:

1. Goal and decided behavior.
2. Repository, cwd, baseline, and exact implementation seam.
3. Mandatory instruction and rule files, using verified absolute paths when the child runs outside the parent cwd.
4. Closed editable paths and explicit do-not-touch paths.
5. Acceptance criteria mapped to named tests or checks.
6. Exact focused commands and required behavioral evidence.
7. Mutation proof for new regression tests when practical: name the smallest mutation that must make each test fail.
8. Authority boundary: edit allowed paths; do not commit, push, merge, publish, release, or broaden scope.
9. Stop rules for ambiguity, missing credentials, conflicting instructions, or an unapproved decision.
10. Handoff: changed files, implementation summary, commands with results, evidence, residual risks, and decisions still needed.

Prefer outcome and evidence over a long procedural script. `must` and `never` are for real invariants, not stylistic micromanagement.

## Launch patterns

### One writer

```javascript
subagent({
  workflowScript: `return runs.run("implementation", {
    agent: "worker",
    task: "<resolved worker contract>",
    acceptance: {
      level: "checked",
      evidence: ["changed-files", "tests-added", "commands-run", "residual-risks"]
    }
  })`,
  async: true
})
```

Use the worker's default context unless a fresh child is intentional. Do not set tight turn, tool, or usage budgets on mutation-capable children; use narrow scope and a reasonable elapsed deadline instead.

### Independent parallel lanes

```javascript
subagent({
  workflowScript: `return runs.all([
    { key: "slice-api", agent: "worker", task: "<API slice contract>", worktree: true },
    { key: "slice-cli", agent: "worker", task: "<CLI slice contract>", worktree: true }
  ])`,
  worktree: true,
  context: "fresh",
  async: true
})
```

Every key, task, output, and file set must be lane-specific. Consume each child's durable handoff manifest and patch; do not infer changes from prose or scrape combined output. Verify and integrate lanes in deterministic slice order. A conflict proves the ownership graph was wrong: repair the graph and rerun the affected slice from the integrated head.

## Verify each slice

Before integration:

1. Derive the actual diff and changed paths from Git and the handoff artifact.
2. Reject changes outside the closed file set.
3. Independently run focused checks. Child-reported command success is evidence, not parent verification.
4. Re-run claimed mutation proofs and confirm the named test fails under the mutation, then restore the implementation.
5. Read every hunk against repository rules and local idiom. Check comments, error handling, hardcoded values, debug leftovers, duplicate abstractions, and vacuous tests.
6. Integrate only verified paths. Never let one lane's green suite stand in for another's.

## Gate the integrated phase

After all required slices are integrated:

1. Run all configured phase validation in the integrated worktree.
2. Invoke `/skill:pi-review` over the complete baseline-to-head diff.
3. Synthesize findings; do not forward raw reviewer output directly to a writer.
4. Send accepted fixes to one writer. Use a managed repair worktree when the active branch must remain stable.
5. Resume retained reviewers only to verify their named findings and exact fix hunks. Use the latest returned run ID after every resume.
6. If a fix materially changes the diff, rerun affected checks and the necessary focused review.
7. Run a fresh final review of the complete final diff when risk or project policy warrants it. Prefer a different model family or provider when available, but never weaken capability, data, or cost policy merely to claim cross-family review.

Stop after three review/fix rounds by default. Stop sooner when no blocker or fix worth doing now remains. If the same invariant survives two fixes, several findings share one root cause, or evidence conflicts, use `/skill:pi-review`'s circuit breaker and replan rather than continuing whack-a-mole.

## Completion gate

Complete a slice or plan item only when:

- acceptance behavior and required checks pass;
- no empirically verified or probed Critical/High regression or newly reachable defect remains;
- every Medium/Low finding is fixed, backlogged with a link, or accepted under project policy with rationale;
- parent verification covers actual changed paths;
- plan, handoff, and risk records are updated where applicable.

Commit only at the authorized task or phase boundary. Stage exact paths, use repository commit conventions, and never push, merge, publish, deploy, or release without explicit authority.

## Failure handling

- Missing or disabled agent: stop and report the failed preflight.
- Dirty tree blocks managed worktrees: preserve it; use one writer or ask how to isolate the work.
- Child fails or times out: inspect lifecycle artifacts and Git before deciding whether edits landed. A missing result is not success.
- `needs_attention`: inspect or steer only when genuinely blocked; do not poll or interrupt normal long-running work.
- Unapproved decision: escalate to the user.
- Non-converging review: stop, preserve evidence, and replan.

Remove temporary outputs and run-owned worktrees only through Pi's managed cleanup evidence. Report every retained path and failed safety check.
