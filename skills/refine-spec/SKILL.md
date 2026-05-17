---
name: refine-spec
description: Read a draft spec file (idea.md, mvp.md, prd.md, brief.md, plan.md, spec.md, etc.) and interactively quiz the user across multiple rounds with AskUserQuestion to fill gaps, resolve ambiguity, and revamp the document into its final form. Use when asked to "refine my idea", "tighten this spec", "turn this into an MVP doc", "interrogate my brief", "polish this PRD", "ask me questions about idea.md", or when the user points at a draft document and wants it sharpened through Q&A.
---

# Refine Spec

Transform a rough draft spec into a finalized document by reading it, identifying gaps, asking the user targeted clarifying questions in multiple rounds via AskUserQuestion, then rewriting the file in place.

## Inputs

The user will name a target file (e.g., `idea.md`, `mvp.md`, `prd.md`, `spec.md`, `brief.md`). If no path is given, search the current directory for likely candidates and confirm with the user before proceeding.

## Process

### 0. Discover local context (greenfield projects only — skip for in-progress refines)

**This step matters most when the user is starting fresh on a box they already operate.** Before asking the user *any* question about stack/infra/conventions, do a non-blocking scan to surface what they already run. Defaults proposed in later rounds should match the user's existing patterns, not generic best-practice.

What to scan:

```bash
ls ~/                                  # sibling project dirs — adjacent stacks
cat ~/*/CLAUDE.md 2>/dev/null          # absorb existing CLAUDE conventions
cat ~/*/AGENTS.md 2>/dev/null          # absorb existing AGENTS conventions
gh repo list <user> --limit 50         # existing repos available as targets
systemctl list-units --type=service \
  --state=running 2>/dev/null          # already-running services on the box
ls ~/.config/ 2>/dev/null              # existing tool configs (cloudflared, rclone, gh, etc.)
which docker podman caddy nginx \
  cloudflared rclone 2>/dev/null       # already-installed infra binaries
test -f ~/.cloudflared/config.yml \
  && cat ~/.cloudflared/config.yml     # cloudflared tunnel ingress (if present)
```

For each discovered tool/service/repo, note:
- Is the user *already* using this for similar work?
- Could the spec adopt it instead of proposing a fresh greenfield choice?

Surface findings to the user in a single tight summary before Round 1, e.g.:

> "Discovery scan: you already run cloudflared (tunnel for `<existing-site>`), have a Cloudflare account, run nginx for `<other-site>`, have repos `<a>`, `<b>`, `<c>` available as content targets, and use `~/golden-horizons/CLAUDE.md` patterns. I'll bias Round 1 toward reusing these. Push back if you want greenfield instead."

This gates against the failure mode where the skill defaults to "best practice" choices (e.g., proposing Backblaze when the user already pays Cloudflare; proposing Caddy when the user already runs cloudflared tunnels; proposing fresh repos when umbrella patterns exist).

**Skip Round 0** if the draft spec already references the user's actual stack OR if the user explicitly asks for a greenfield-best-practice pass.

### 1. Read & Diagnose

Read the target file in full. Build a mental model of:
- **Stated**: what the doc explicitly claims/specifies
- **Implied**: what's hinted at but not nailed down
- **Missing**: critical sections a finalized version of this doc-type needs but lacks
- **Contradictions / ambiguity**: anything that conflicts or could be read multiple ways

Match the document's apparent type (idea note, MVP scope, PRD, technical spec, marketing brief, etc.) and use that to anchor what "finalized form" means.

### 2. Plan Question Rounds

Use Round 0 findings to bias every default in every later round. When an option matches the user's existing stack, mark it "(Recommended)" with the discovery reference (e.g., "Cloudflare R2 (Recommended — you already pay Cloudflare)"). Generic best-practice options come second.

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

- **Discover before defaulting.** Run §0 (Discovery) first on greenfield projects. Bias every Round 1+ default toward the user's existing stack. Generic best-practice answers are the fallback, not the lead.
- **Don't ask everything at once.** Multi-round is the point — it gives the user time to think and you time to adapt later questions to earlier answers.
- **Don't ask what the doc already answers.** Read first, ask second.
- **Don't ask what discovery already answers.** If `~/.cloudflared/config.yml` exists, don't ask "what reverse proxy?" — propose the existing tunnel.
- **Don't fabricate.** If the user skips a question, mark the section as open rather than filling with plausible-sounding content.
- **Stay in the file.** Edit the target in place. Don't spawn `idea-v2.md`, `idea-final.md`, etc. unless the user asks.
- **Stop when diminishing returns hit.** If the user starts giving terse "whatever you think" answers, wrap up — don't drag them through more rounds.
