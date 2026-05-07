---
name: refine-spec
description: Read a draft spec file (idea.md, mvp.md, prd.md, brief.md, plan.md, spec.md, etc.) and interactively quiz the user across multiple rounds with AskUserQuestion to fill gaps, resolve ambiguity, and revamp the document into its final form. Use when asked to "refine my idea", "tighten this spec", "turn this into an MVP doc", "interrogate my brief", "polish this PRD", "ask me questions about idea.md", or when the user points at a draft document and wants it sharpened through Q&A.
---

# Refine Spec

Transform a rough draft spec into a finalized document by reading it, identifying gaps, asking the user targeted clarifying questions in multiple rounds via AskUserQuestion, then rewriting the file in place.

## Inputs

The user will name a target file (e.g., `idea.md`, `mvp.md`, `prd.md`, `spec.md`, `brief.md`). If no path is given, search the current directory for likely candidates and confirm with the user before proceeding.

## Process

### 1. Read & Diagnose

Read the target file in full. Build a mental model of:
- **Stated**: what the doc explicitly claims/specifies
- **Implied**: what's hinted at but not nailed down
- **Missing**: critical sections a finalized version of this doc-type needs but lacks
- **Contradictions / ambiguity**: anything that conflicts or could be read multiple ways

Match the document's apparent type (idea note, MVP scope, PRD, technical spec, marketing brief, etc.) and use that to anchor what "finalized form" means.

### 2. Plan Question Rounds

Group questions into **3–5 thematic rounds**, ordered from foundational to detailed. Typical progression:

1. **Vision / problem** — who is this for, what problem, why now
2. **Scope** — in vs out, MVP vs later, success criteria
3. **Mechanics** — how it works, key flows, constraints
4. **Edge cases & open decisions** — tradeoffs, risks, unresolved choices
5. **Polish** — naming, tone, format, distribution

Skip rounds that the draft already answers cleanly. Add rounds if the doc-type demands it.

### 3. Ask in Batches via AskUserQuestion

For each round, batch **2–4 related questions** into a single AskUserQuestion call (the tool supports up to ~5 questions per call). For each question:
- Provide 3–4 concrete multiple-choice options when the answer space is enumerable
- Always include an open-ended escape hatch by letting the user supply a custom answer
- Keep question text tight; put nuance in the option labels

Between rounds, briefly acknowledge what you learned (one sentence) before launching the next batch — so the user feels heard, not interrogated.

### 4. Synthesize & Rewrite

After the final round:
- Rewrite the target file in place with Edit/Write
- Preserve the user's voice and any strong existing prose
- Add/restructure sections so the doc reads as a finalized version of its type
- Mark any remaining unknowns explicitly as `**Open question:**` rather than guessing
- Do **not** invent facts the user didn't supply — the rule is fill from answers, flag the rest

### 5. Confirm

End with a short summary: what changed, what's still open, suggested next step (e.g., "ready to share with stakeholders" or "needs one more pass on pricing").

## Guardrails

- **Don't ask everything at once.** Multi-round is the point — it gives the user time to think and you time to adapt later questions to earlier answers.
- **Don't ask what the doc already answers.** Read first, ask second.
- **Don't fabricate.** If the user skips a question, mark the section as open rather than filling with plausible-sounding content.
- **Stay in the file.** Edit the target in place. Don't spawn `idea-v2.md`, `idea-final.md`, etc. unless the user asks.
- **Stop when diminishing returns hit.** If the user starts giving terse "whatever you think" answers, wrap up — don't drag them through more rounds.
