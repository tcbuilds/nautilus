---
name: roadmap
description: Create or update implementation_plan.md with the smallest useful set of Markdown task checkboxes. Use when asked to plan a project, create a task list, organize implementation, identify what needs to be done, or update an existing implementation plan.
---

# Implementation Plan Manager

Create or update an `implementation_plan.md` file with Markdown task checkboxes for tracking project tasks. Scale the plan to the request: a simple fix may need one vertical slice and one verification step; a larger project may need phases.

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
- "Add compliance process" — add only when the project handles controlled data, customer confidential data, production access, enterprise delivery, or an explicit audit/security requirement.
- "Run every audit skill" — slop unless the project shape calls for it. Pick the narrow gate that controls the actual risk.

**Default to less.** The smallest plan that fully ships beats a large plan that suffocates. If you're unsure whether a task belongs, ask the user instead of emitting it.

## Smallest solution first

Before emitting tasks, stop at the first option that fully meets the request:

1. Skip work that is not needed.
2. Reuse an existing helper, type, component, or pattern.
3. Prefer the standard library or native platform.
4. Prefer an already-installed dependency over adding one.
5. Plan only the minimum new code that works.

Do not plan speculative abstractions, scaffolding, dependencies, configuration, refactors, compatibility machinery, or future-proofing. Trace the real flow and fix shared root causes once instead of planning repeated symptom patches. Preserve security, trust-boundary validation, accessibility, and data-loss protection.

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
- **Enterprise / compliance-sensitive repo**: include only the governance gates that match the data and delivery risk: data classification, ADR/risk register, hardening audit, secure code review, release readiness, and MR/pipeline evidence.
- **Internal tool / script**: minimal scaffolding. Skip almost all infra tasks.
- **Library / SDK published to a registry**: include release automation, version tagging, changelog discipline. Skip deploy/infra.

The shape determines which "best practice" tasks are real commitments vs. ritual.

## Repo-first discovery

Before adding any process, tooling, CI, testing, formatting, security, deployment, or release task, inspect how the current repo already works. Existing repo evidence beats generic preference.

Check for:

- Platform and workflow: `git remote -v`, `.gitlab-ci.yml`, `.github/workflows/`, merge/pull request templates, CODEOWNERS.
- Project commands: README, Makefile, package scripts, pyproject, Cargo.toml, justfile, taskfile, tox, nox.
- Existing quality gates: test commands, lint/typecheck commands, coverage config, security scans, dependency checks.
- Existing docs: CLAUDE.md, AGENTS.md, codingStandards.md, CONTRIBUTING.md, SECURITY.md, ADRs, runbooks.
- Existing architecture: source directories, tests, migrations, deployment manifests, Dockerfiles, infra files.

Planning rules:

- If the repo already has a gate, use that gate by name instead of proposing a new tool.
- If the repo has no evidence for a tool, do not add it unless the spec, user intent, or known failure requires it.
- If the repo has a lightweight manual workflow that fits the project shape, preserve it.
- If a stronger gate is genuinely required, explain the repo evidence and the risk that justifies adding it.
- If discovery is inconclusive, ask one focused question instead of filling the plan with generic setup tasks.

## CodeGraph blast radius

For structural code questions, use CodeGraph instead of grep when the project has a `.codegraph/` index:

1. Use `codegraph_context` to find the relevant flow, symbols, and definitions.
2. Use `codegraph_impact` on symbols the plan proposes changing.
3. Use `codegraph_callers` or `codegraph_callees` only when more focused call-path detail is needed.
4. Record affected callers, entry points, public contracts, persisted data, and relevant tests in the plan. Do not copy raw tool output into the plan.

Trust CodeGraph results; do not re-verify them with grep. Use `rg` for literal text only. If CodeGraph is not initialized, ask: "I notice this project doesn't have CodeGraph initialized. Want me to run `codegraph init -i` to build the index?"

## Platform language

Detect the repository host before writing process tasks:

- GitLab repo: use merge request, pipeline, protected branch, approval rule, environment, project, and group.
- GitHub repo: use pull request, Actions, branch protection, environment, and repository.
- Unknown or platform-neutral: use MR/PR and CI pipeline.

Do not generate GitHub Actions tasks for GitLab repositories. Do not generate GitLab CI tasks for GitHub repositories unless the repo already uses that pattern.

## Compatibility

Do not add backward-compatibility shims, aliases, dual paths, deprecation layers, or migrations unless the user or project requirements explicitly require compatibility.

Do not silently break an existing public API, persisted data format, CLI contract, integration, or user workflow. Surface the break as an explicit decision. Add migration work only after the break or compatibility requirement is approved.

## Instructions

1. **If implementation_plan.md doesn't exist:**
   - Read the spec file(s) the user points at (mvp.md, prd.md, brief.md). If none exists, ask.
   - Read applicable project instructions and `context/resources/` before guessing.
   - Read CLAUDE.md and any standards docs (codingStandards.md) for project-specific rules.
   - Run repo-first discovery and summarize existing commands, gates, platform, and docs before planning.
   - Trace the real flow and use CodeGraph blast-radius analysis for structural changes when indexed.
   - Identify project shape (see above). If ambiguous, ask before generating.
   - Identify platform shape (GitLab, GitHub, other, unknown) from remotes and existing CI files.
   - Generate the plan: every task traces to spec / user intent / known failure.
   - Use Markdown task checkboxes: `- [ ]` for incomplete, `- [x]` for complete.
   - End the plan with a short `## Deferred / Out of scope` section listing notable things you considered and *intentionally* did not include — this makes scope decisions auditable.

2. **If implementation_plan.md already exists:**
   - Read the current file.
   - Review what's complete vs. remaining.
   - Update it directly from the user's request.
   - Preserve completed work, remove stale duplication, and avoid reorganizing unaffected sections.

3. **Structure the plan with:**
   - Clear section headers grouped by milestone or capability (## M0 — Scaffolding, ## M1 — Core feature, etc.)
   - Parent tasks with nested sub-tasks using proper indentation.
   - Priority indicators where relevant (High, Medium, Low).
   - Estimated effort only when the spec or user has anchored a timeline.
   - Links to related spec sections, files, or issues — task-to-source traceability.
   - Concrete acceptance criteria and the smallest relevant test, build, lint, or runtime check.
   - Review gates only where they control real risk. For secure-delivery projects, prefer explicit gates such as `/data-classification`, `/secure-code-review`, `/codex-review`, `/hardening-audit`, and `/release-readiness` at the milestone where their evidence is needed.

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

## Secure-delivery example

For an enterprise or compliance-sensitive repo, add gates only where risk requires them:

```markdown
## M0 — Delivery controls
- [ ] Classify project data flows with `/data-classification` before implementing storage, logging, prompts, or integrations.
- [ ] Record ADR for auth, storage, deployment, or LLM/MCP decisions that are hard to reverse.

## M1 — Feature slice
- [ ] {feature from spec §X}
  - [ ] Implement behavior end-to-end.
  - [ ] Add tests for accepted and rejected paths.
  - [ ] Run `/codex-review` on changed files before marking complete.

## Release gate
- [ ] Run `/hardening-audit` for production, auth, API, LLM, MCP, or infrastructure changes.
- [ ] Run `/release-readiness` before merge/deploy/customer delivery.
```

If the project does not handle sensitive data, production access, or customer-facing delivery, defer these gates rather than adding them by default.

## Final check

Before saving, verify that:

- Every task traces to the spec, explicit user intent, or a concrete failure.
- Every task contributes directly to the requested outcome.
- Blast radius and contract risks are represented.
- No simpler existing solution was missed.
- No speculative compatibility or architecture work slipped in.
- Completion state and acceptance criteria are verifiable.
