# Phase 4 — Build

Execute the plan. From here on, the workflow runs mostly through skills and agents.

## What to run

`/build`. It reads `implementation_plan.md` and dispatches specialized agents (via the Agent tool) to execute tasks.

## Orchestrator discipline

Top-level Claude Code remains an orchestrator. It does not write code, run commands, or make edits directly. Every task is delegated to a specialist:

- Python core work → `python-core-engineer`
- Performance work → `performance-optimizer`
- Git/CI/repo ops → `github-master`
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

## What carries you the rest of the way

Once Phase 0 is solid and the build loop is humming, the remaining work flows naturally through skills and agents. The orchestrator's job becomes choosing the next task, picking the right specialist, verifying the result, and committing. That's it.

## Reminder

Ship and earn beats polished and sitting in a repo. Every phase that's verified, committed, and pushed is value captured. Every phase that's "almost ready" is value at risk.
