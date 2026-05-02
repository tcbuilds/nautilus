# Phase 2 — Init

Generate the project's `CLAUDE.md` so every future Claude Code session in this repo plays by the right rules.

## What to run

The Claude Code `/init` command. It scans the codebase and produces a `CLAUDE.md` at the project root.

## What the generated `CLAUDE.md` MUST contain

Two non-negotiables:

1. **Mandatory agent delegation.** The top-level Claude Code session is an orchestrator only. It never writes code, runs commands, or makes edits directly. All implementation work flows through specialized agents invoked via the Agent tool. Subagents executing under that orchestrator *are* the specialists and must ship — they don't refuse implementation work by citing the orchestrator rule.

2. **Adherence to `codingStandards.md`** as the ground-truth rules for code style, comments, data handling, file management, git workflow, and process management. The CLAUDE.md should reference the standards file directly rather than restating it.

## When `/init` output isn't strong enough

Use `templates/CLAUDE.md.template` as the starting boilerplate. Either:

- Replace the `/init` output entirely with the template and customize the project-specific sections, or
- Merge the strongest parts of `/init`'s output into the template skeleton.

The template exists because `/init` is good at codebase summary but uneven at encoding workflow rules. The merge gives you both.

## Exit criteria

`CLAUDE.md` is committed, references `codingStandards.md`, encodes the orchestrator/delegation rules explicitly, and the project is ready for roadmapping.
