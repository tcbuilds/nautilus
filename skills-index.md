# Skills Index

Quick reference for the Claude Code skills used in the nautilus workflow.

| Skill | Purpose | Workflow phase |
|---|---|---|
| `/refine-spec` | Interactively quiz the user across multiple rounds to fill spec gaps and resolve ambiguity in `mvp.md` / `idea.md`. | Phase 1 — Spec Refinement |
| `/init` | Scan the codebase and generate the project's `CLAUDE.md` with orchestrator rules and standards references. (Claude Code built-in, not shipped here.) | Phase 2 — Init |
| `/roadmap` | Generate `implementation_plan.md` with GitHub-style checkbox phases from the refined spec. | Phase 3 — Roadmap |
| `/build` | Read `implementation_plan.md` and dispatch specialized agents to execute tasks one phase at a time. | Phase 4 — Build |
| `/hardening-audit` | Audit web apps, APIs, LLM integrations, and MCP/agent tool surfaces for production hardening gaps. | Cross-cutting — Security |
| `/compliance-review` | Review repository evidence and gaps for regulated-environment readiness without claiming certification. | Cross-cutting — Compliance |
| `/data-classification` | Classify data flows, storage, logs, prompts, MCP outputs, and retention rules. | Cross-cutting — Data governance |
| `/secure-code-review` | Review diffs and architecture for exploitable security defects and unsafe defaults. | Cross-cutting — Security |
| `/release-readiness` | Build go/no-go evidence before merge, deploy, delivery, or public release. | Cross-cutting — Release |
| `/adr-risk-register` | Record consequential decisions, alternatives, risks, owners, and mitigations. | Cross-cutting — Governance |
| `/nautilus-sync` | Sync a local skill or agent into a public-facing nautilus-shaped playbook repo as a sanitized loadable artifact. | Phase 7 — Maintaining the Playbook |

This index will grow as more skills get adopted into the workflow. New entries belong here only after a skill has been used on at least two projects with consistent results. Per-skill detail files live under `skills/`.
