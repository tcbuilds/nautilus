---
name: roadmap
description: Create or update implementation_plan.md with Markdown task checkboxes. Use when asked to "plan the project", "create a task list", "what needs to be done", or "organize implementation steps".
---

# Implementation Plan Manager

Create or update an `implementation_plan.md` file with Markdown task checkboxes for tracking project tasks.

## Anti-slop rules (read first)

A roadmap is a list of *commitments*, not a list of best-practice rituals. Every task you emit must trace to one of:

1. **The spec** (mvp.md, prd.md, brief.md, etc.) — quote or reference the spec line.
2. **Explicit user intent** in this conversation.
3. **A concrete failure** the project has already hit.

If a task doesn't trace to one of those three, it's slop. Common slop patterns to **NOT emit by default**:

- "Set up CI/CD pipeline" — only if the spec requires CI as the venue for something specific (eval harness, anti-goal enforcement, team gating). A solo dev who runs gates manually does not need CI on every merge request or pull request.
- "Add pre-commit hooks" / "husky" / "lint-staged" — friction without payoff for solo projects. Add only when a collaborator-shaped failure has happened (someone pushed broken code).
- "Branch protection on main" — theater on a solo repo. Add only when collaborators land or MR/PR review becomes a real workflow.
- "Set up Dependabot / Renovate" — add only when the spec calls for security posture or dependency rot is an actual concern.
- "Add Storybook" / "Add Sentry" / "Add OpenTelemetry" — add only when the spec or a real failure asks for it.
- "Add monitoring / alerting" — load-bearing for production services, slop for local-first tools.

**Default to less.** A 50-task plan that ships beats a 200-task plan that suffocates. If you're unsure whether a task belongs, ask the user instead of emitting it.

## Task shape

Every task = one user-visible behavior built end-to-end (UI + logic + data + test). Under 2 days of work. Demoable when done.

No horizontal "set up the database" or "build the API layer" tasks. Those are not tasks — they hide inside a feature task. A real task lands a slice of the product, top to bottom.

Bad task: "Set up the database."
Good task: "Add user signup endpoint that persists to the users table, returns a session token, and has integration test coverage."

If the task is too big to ship in 2 days, split it into thinner vertical slices, not horizontal layers.

## Project shape — ask before planning

Before writing the plan, identify the project shape. Use AskUserQuestion if the answer isn't obvious from the codebase + spec:

- **Solo private-to-public OSS tool** (one dev, no MR/PR review, ships when ready): skip CI-on-MR/PR, skip pre-commit, skip branch protection. Keep distribution + eval + anti-goal guards if the spec calls for them.
- **Team SaaS / production service**: CI, branch protection, monitoring, alerting are load-bearing. Include them.
- **Internal tool / script**: minimal scaffolding. Skip almost all infra tasks.
- **Library / SDK published to a registry**: include release automation, version tagging, changelog discipline. Skip deploy/infra.

The shape determines which "best practice" tasks are real commitments vs. ritual.

## Instructions

1. **If implementation_plan.md doesn't exist:**
   - Read the spec file(s) the user points at (mvp.md, prd.md, brief.md). If none exists, ask.
   - Read CLAUDE.md and any standards docs (codingStandards.md) for project-specific rules.
   - Identify project shape (see above). If ambiguous, ask before generating.
   - Generate the plan: every task traces to spec / user intent / known failure.
   - Use Markdown task checkboxes: `- [ ]` for incomplete, `- [x]` for complete.
   - End the plan with a short `## Deferred / Out of scope` section listing notable things you considered and *intentionally* did not include — this makes scope decisions auditable.

2. **If implementation_plan.md already exists:**
   - Read the current file.
   - Review what's complete vs. remaining.
   - Ask the user what they want: add tasks, mark complete, reorganize, archive done sections, prune slop.

3. **Structure the plan with:**
   - Clear section headers grouped by milestone or capability (## M0 — Scaffolding, ## M1 — Core feature, etc.)
   - Parent tasks with nested sub-tasks using proper indentation.
   - Priority indicators where relevant (High, Medium, Low).
   - Estimated effort only when the spec or user has anchored a timeline.
   - Links to related spec sections, files, or issues — task-to-source traceability.

4. **Example format** (deliberately minimal — do NOT pad with infra unless the spec requires it):

```markdown
## M0 — Foundations
- [x] Initialize repo
- [ ] Scaffold backend per spec §6
- [ ] Define core data model per spec §6.2

## M1 — Core feature
- [ ] {feature from spec §X}
  - [ ] {sub-task tracing to spec line Y}

## Cross-cutting
- [ ] Tests covering critical paths (per spec §testing)

## Deferred / Out of scope (this iteration)
- CI on MR/PR — solo dev, manual gates suffice for now
- Branch protection — no collaborators yet
- {anything else considered and dropped}
```

Notice the example does **not** include "Set up CI/CD pipeline" or "pre-commit hooks." Those are only added when a spec line or explicit user request demands them.
