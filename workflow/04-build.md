# Phase 4 — Build

Execute the plan. From here on, the workflow runs mostly through skills and agents.

## What to run

Choose the active harness's native workflow:

- **Claude Code:** `/claude-build` reads `implementation_plan.md` and dispatches specialized agents through the Agent tool.
- **Pi:** `/skill:pi-implement` reads the same plan and coordinates `worker`, `reviewer`, and optional `oracle` roles through `pi-subagents`. It uses one writer per worktree, Pi-managed isolation for safe parallel lanes, and `/skill:pi-review` for the independent gate.
- **Codex-backed flows:** `/codex-implement` remains available when its external CLI/profile workflow is intentionally required.

Do not make one harness shell out to another merely to obtain implementation or review.

## Orchestrator discipline

The top-level session remains the decision-maker and gate owner. In Claude Code, repository policy may require strict orchestrator-only behavior: no direct edits or commands, with every task delegated to a specialist. In Pi, `/skill:pi-implement` follows its native parent-owned contract: the parent resolves design, scopes work, verifies evidence, and owns Git while one `worker` writes in each active worktree.

Common Claude Code specialist routing includes:

- Python core work → `python-core-engineer`
- Performance work → `performance-optimizer`
- Git/CI/repo ops → `git-platform-engineer` (use `github-master` only for GitHub-specific work)
- Codebase exploration → `Explore`
- Network/connectivity issues → `network-diagnostics`
- And so on — see `agents-index.md` and the global agent list.

Always pass `model="opus"` on Agent calls. Never use `general-purpose` — pick the specialist.

## Sequencing

Start with Phase 0 of the plan. Finish it. Then Phase 1. Then Phase 2. Resist the urge to jump ahead — each phase exists because later phases assume it works.

## End-of-phase ritual

After every phase:

1. **Verify it works.** Run tests, hit the endpoint, exercise the CLI. Don't trust "looks right."
2. **Commit** with a descriptive message that explains *why* the changes were made, not just what changed.
3. **Push only once the owner OKs it.** Commit locally at the phase boundary and report the phase result plus the commit SHA — in a repo where a push triggers deploys, scans, or keyword-activated pipelines, pushing is a production event, not a bookkeeping step.

## Proven enforcement lessons

- Keep edit-time feedback fast and advisory when a task is still incomplete. Enforce cumulative requirements, such as adding tests for new behavior, at the final task gate.
- A compressed replay may replace an elapsed dogfood window only with explicit owner approval. Record the scenarios covered and what the replay cannot prove; never claim historical commands ran when they were substituted.
- Preserve failed release tags and attempts. Fix forward with a new version so the deployment record remains auditable.
- Make review independent of implementation, but executor-aware. Pi uses fresh-context `/skill:pi-review` reviewers and may choose a different capable model family when policy and availability allow it. Codex-backed flows use `/codex-review`; do not dispatch a redundant external reviewer when the active harness already provides an equivalent independent gate.
- Treat timeouts as bounded repository configuration. A universal short limit can turn a slow passing suite into false evidence.

## What carries you the rest of the way

Once Phase 0 is solid and the build loop is humming, the remaining work flows naturally through skills and agents. The orchestrator's job becomes choosing the next task, picking the right specialist, verifying the result, and committing. That's it.

## Reminder

Ship and earn beats polished and sitting in a repo. Every phase that's verified and committed is value captured, with the push following on the owner's OK. Every phase that's "almost ready" is value at risk.
