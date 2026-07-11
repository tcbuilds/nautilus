# Phase 4 — Build

Execute the plan. From here on, the workflow runs mostly through skills and agents.

## What to run

`/build`. It reads `implementation_plan.md` and dispatches specialized agents (via the Agent tool) to execute tasks.

## Orchestrator discipline

Top-level Claude Code remains an orchestrator. It does not write code, run commands, or make edits directly. Every task is delegated to a specialist:

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
3. **Push.**

## Proven enforcement lessons

- Keep edit-time feedback fast and advisory when a task is still incomplete. Enforce cumulative requirements, such as adding tests for new behavior, at the final task gate.
- A compressed replay may replace an elapsed dogfood window only with explicit owner approval. Record the scenarios covered and what the replay cannot prove; never claim historical commands ran when they were substituted.
- Preserve failed release tags and attempts. Fix forward with a new version so the deployment record remains auditable.
- Make review independent of implementation, but executor-aware. When the active model is already Codex, review the diff directly instead of dispatching a redundant `codex-review` subagent. Other harnesses may keep their own independent reviewer.
- Treat timeouts as bounded repository configuration. A universal short limit can turn a slow passing suite into false evidence.

## What carries you the rest of the way

Once Phase 0 is solid and the build loop is humming, the remaining work flows naturally through skills and agents. The orchestrator's job becomes choosing the next task, picking the right specialist, verifying the result, and committing. That's it.

## Reminder

Ship and earn beats polished and sitting in a repo. Every phase that's verified, committed, and pushed is value captured. Every phase that's "almost ready" is value at risk.
