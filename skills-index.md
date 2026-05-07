# Skills Index

Quick reference for the Claude Code skills used in the nautilus workflow.

| Skill | Purpose | Workflow phase |
|---|---|---|
| `/refine-spec` | Interactively quiz the user across multiple rounds to fill spec gaps and resolve ambiguity in `mvp.md` / `idea.md`. | Phase 1 — Spec Refinement |
| `/init` | Scan the codebase and generate the project's `CLAUDE.md` with orchestrator rules and standards references. (Claude Code built-in, not shipped here.) | Phase 2 — Init |
| `/roadmap` | Generate `implementation_plan.md` with GitHub-style checkbox phases from the refined spec. | Phase 3 — Roadmap |
| `/build` | Read `implementation_plan.md` and dispatch specialized agents to execute tasks one phase at a time. | Phase 4 — Build |
| `/nautilus-sync` | Sync a personal skill or agent from `~/.claude/` into a public-facing nautilus-shaped playbook repo as a sanitized loadable artifact. | Phase 7 — Maintaining the Playbook |

This index will grow as more skills get adopted into the workflow. New entries belong here only after a skill has been used on at least two projects with consistent results. Per-skill detail files live under `skills/`.
