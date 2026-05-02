# Phase 1 — Spec Refinement

Take the raw discovery doc and turn it into something a build process can actually consume.

## Where it happens

Claude Code, in the project directory. The `mvp.md` or `idea.md` from Phase 0 is now in the repo.

## What to run

The `/refine-spec` skill. It reads the draft and interactively quizzes the user across multiple rounds via `AskUserQuestion`, filling gaps, resolving ambiguity, and revamping the document into final form.

## Prerequisites

`templates/codingStandards.md` should already be copied into the project at this point. Architecture decisions made during refinement need to honor those standards (no mock data, no testnet defaults, real implementations only, etc.). If the standards aren't present, the spec can drift in directions that the build phase will have to undo.

## How to use it well

- Run it once for a baseline pass.
- Re-run it with a targeted prompt when you want deeper interrogation on a specific axis. Examples: "ask harder questions about the data model," "drill into auth and session handling," "find the parts of this that are hand-wavy about scale."
- Treat every round as a chance to surface the assumptions you didn't know you were making.

## Exit criteria

The spec is fully scoped and there is no major ambiguity left. Someone unfamiliar with the project should be able to read the refined doc and produce a roadmap from it without having to ask the user clarifying questions.

If you're tempted to "figure it out during the build" on something architectural, refine more first.
