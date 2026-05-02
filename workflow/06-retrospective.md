# Phase 6 — Retrospective

The playbook is a living asset; so is the project. After each phase of the implementation plan, and again at end-of-project, run a retrospective. Solo retros work — the discipline is the writing, not the meeting.

## When to retro

- After each phase of the `implementation_plan.md`.
- After every customer-impacting incident (the postmortem doubles as a partial retro).
- At end of project, before flipping to maintenance mode.

## DORA scoreboard (solo edition)

Track four numbers per project. Eyeball them after each retro. The goal is direction of travel, not absolute targets — solo numbers will not match elite-team benchmarks, and that is fine.

| Metric | What it measures | How to track |
|---|---|---|
| **Deployment frequency** | Throughput | Count deploys per week. |
| **Lead time for changes** | Throughput | Median commit-to-prod time. |
| **Change failure rate** | Stability | Share of deploys that needed a rollback or hot-fix. |
| **Recovery time** | Stability | Time from incident detection to mitigation. |

Movement matters more than absolute values. If failure rate is climbing, slow down and find why.

## Retro template

Five sections, no preamble.

### What worked

Concrete artifacts: this skill, this agent, this template, this rule, this commit pattern. List them.

### What did not work

Specific frictions. "Skill X kept failing on Y," "agent Z misread the spec," "I lost three hours on W." Name the thing.

### What surprised me

The most underrated section. Surprises are signals you don't yet have a model for. Capture them even when they are positive.

### What to try next

Concrete next experiments. New skill to build, new agent pattern to try, new check to add to the standards. One sentence each.

### Action items

| Owner | Action | Due date |
|---|---|---|
| me | ... | YYYY-MM-DD |

## Feed the playbook

Every retro is an input to nautilus. If a skill, agent, template, or rule earns its place across multiple projects, promote it via `/nautilus-sync` (Phase 5). If a rule fails repeatedly, retire it. The playbook reflects what works in practice — not what was speculated up front.

## Exit criteria

Retro doc is written and saved with the project. DORA numbers are recorded. Action items are tracked. Anything graduating to the playbook is on the `/nautilus-sync` queue.
