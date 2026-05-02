# Phase 3 — Roadmap

Turn the refined spec into a sequenced, checkbox-trackable plan.

## What to run

The `/roadmap` skill, against the refined `mvp.md` or `idea.md`.

## Output

`implementation_plan.md` at the project root. GitHub-style markdown checkboxes, organized into phases.

## Phase 0 of the roadmap is always foundational

Phase 0 in the generated plan is the scaffolding work: repo init, dependency install, base directory structure, environment configuration, lint/test setup, CI skeleton. It is not the product. Get this right and the rest goes faster; get it wrong and every later phase has friction.

## Subsequent phases

Each phase breaks the MVP into a shippable increment. A phase should end with something demonstrable — a route that responds, a script that runs end-to-end, a CLI that does one thing — not a half-wired internal component.

## Task granularity

Each task in the plan should be self-contained enough that a specialized agent can execute it given just the task description plus the repo context. If a task requires the agent to first understand five other tasks to even start, split it.

Good task: "Add Postgres connection pool config in `src/db/pool.ts`, expose `getPool()` factory, write tests for connect/disconnect lifecycle."

Bad task: "Set up the database."

## Exit criteria

`implementation_plan.md` exists, Phase 0 covers all foundational work, every subsequent task is scoped tightly enough to delegate, and the plan as a whole covers the spec without gaps.
