# Phase 3 — Roadmap

Turn the refined spec into a sequenced, checkbox-trackable plan.

## What to run

The `/roadmap` skill, against the refined `mvp.md` or `idea.md`.

## Output

`implementation_plan.md` at the project root. Markdown task checkboxes, organized into phases.

## Foundations are conditional

Add a foundational phase only when the request or repository actually needs one. Reuse existing structure, commands, dependencies, and gates first. For a focused change, begin with the first shippable behavior; do not invent repo initialization, scaffolding, environment configuration, lint/test setup, or CI work by default.

## Subsequent phases

Each phase breaks the MVP into a shippable increment. A phase should end with something demonstrable — a route that responds, a script that runs end-to-end, a CLI that does one thing — not a half-wired internal component.

## Task granularity

Each task in the plan should be self-contained enough that a specialized agent can execute it given just the task description plus the repo context. If a task requires the agent to first understand five other tasks to even start, split it.

Good task: "Add Postgres connection pool config in `src/db/pool.ts`, expose `getPool()` factory, write tests for connect/disconnect lifecycle."

Bad task: "Set up the database."

## Task shape

Every task = one user-visible behavior built end-to-end (UI + logic + data + test). Under 2 days of work. Demoable when done.

No horizontal "set up the database" or "build the API layer" tasks. Those are not tasks — they hide inside a feature task. A real task lands a slice of the product, top to bottom.

Bad task: "Set up the database."
Good task: "Add user signup endpoint that persists to the users table, returns a session token, and has integration test coverage."

If the task is too big to ship in 2 days, split it into thinner vertical slices, not horizontal layers.

## Exit criteria

`implementation_plan.md` exists, every task traces to a requirement or concrete repository risk, each task is scoped tightly enough to delegate, and the smallest complete plan covers the spec without gaps. Persisted-data survival, rollback/recovery, security, and supported public contracts remain protected without speculative compatibility machinery.
