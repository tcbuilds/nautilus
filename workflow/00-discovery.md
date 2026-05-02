# Phase 0 — Discovery

Where ideas get fleshed out before any code or tooling is involved.

## Where it happens

**claude.ai web**, not Claude Code. Long-form back-and-forth in a browser tab is the right environment for this stage. Local CLI sessions burn context on file reads and tool calls; the web chat lets you think out loud across many turns without that overhead.

## Input

A rough idea. Could be one sentence, could be a paragraph, could be a screenshot of something that inspired you.

## Output

A single document checked into the new project's root: `mvp.md` (or `idea.md` if it's still early-stage). A good output contains:

- **Problem statement** — what hurts, who it hurts, why now.
- **Proposed solution** — high-level shape of what you'd build.
- **Scope boundaries** — what's in, what's explicitly out.
- **Success criteria** — how you'll know it worked.
- **Constraints** — tech stack, time budget, money budget, anything fixed by external reality.

Implementation detail stays light. Architecture and stack decisions belong in spec refinement, not here.

## When to leave this phase

When the document is coherent enough to hand to Claude Code for refinement. You don't need every gap filled — that's what Phase 1 is for. You need enough scaffolding that someone reading it understands what you're trying to build and roughly why.

If you can't answer "what is the smallest version of this that's useful," you're not done with discovery yet.
