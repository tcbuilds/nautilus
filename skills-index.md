# Skills Index

Quick reference for the agent skills used in the nautilus workflow.

| Skill | Purpose | Workflow phase |
|---|---|---|
| `/refine-spec` | Interactively quiz the user across multiple rounds to fill spec gaps and resolve ambiguity in `mvp.md` / `idea.md`. | Phase 1 — Spec Refinement |
| `/init` | Scan the codebase and generate the project's `CLAUDE.md` with orchestrator rules and standards references. (Claude Code built-in, not shipped here.) | Phase 2 — Init |
| `/roadmap` | Generate the smallest evidence-backed `implementation_plan.md`, rejecting speculative architecture and compatibility work while preserving data recovery and supported contracts. | Phase 3 — Roadmap |
| `/claude-build` | Read `implementation_plan.md`, dispatch specialized agents phase by phase, and gate every task on an independent Codex review before marking it complete. | Phase 4 — Build |
| `/warmup` | Load repo-local rules, recent git history, current state, commands, and likely next steps for a fresh session. | Cross-cutting — Session start |
| `/handoff` | Write `HANDOFF.md` with current state, decisions, validation, risks, and exact resume steps. | Cross-cutting — Session end |
| `/repo-orientation` | Create `repo_orientation.md` explaining purpose, architecture, commands, tests, deployment, and safe-change workflow. | Cross-cutting — Onboarding |
| `/bro` | Restate the previous response in plain human language with no jargon. | Cross-cutting — Communication |
| `/codex-review` | Run a second-pass Codex review gate over changed files and block Critical/High findings. | Cross-cutting — Review |
| `/codex-implement` | Execute one slice or an implementation-plan task, phase, or full plan through parallel isolated Luna workers and one integrated Astra review per phase. | Phase 4 / Cross-cutting — Implementation |
| `/skill:pi-implement` | Execute a task, phase, or plan through Pi-native workers, managed worktrees, parent verification, and the Pi-native review gate. | Phase 4 / Cross-cutting — Implementation |
| `/skill:pi-review` | Run fresh-context Pi reviewers, synthesize evidence-backed findings, and verify fixes through retained reviewer runs. | Cross-cutting — Review |
| `/hardening-audit` | Audit web apps, APIs, LLM integrations, and MCP/agent tool surfaces for production hardening gaps. | Cross-cutting — Security |
| `/compliance-review` | Review repository evidence and gaps for enterprise or regulated-environment readiness without claiming certification. | Cross-cutting — Compliance |
| `/data-classification` | Classify data flows, storage, logs, prompts, MCP outputs, and retention rules. | Cross-cutting — Data governance |
| `/secure-code-review` | Review diffs and architecture for exploitable security defects and unsafe defaults. | Cross-cutting — Security |
| `/prompt-injection-audit` | Perform a read-only, evidence-based OWASP LLM risk audit with deep coverage of direct and indirect prompt injection. | Cross-cutting — Security |
| `/release-readiness` | Build go/no-go evidence before merge, deploy, delivery, or public release. | Cross-cutting — Release |
| `/adr-risk-register` | Record consequential decisions, alternatives, risks, owners, and mitigations. | Cross-cutting — Governance |
| `/nautilus-sync` | Sync a local skill or agent into a public-facing nautilus-shaped playbook repo as a sanitized loadable artifact. | Phase 7 — Maintaining the Playbook |

This index will grow as more skills get adopted into the workflow. New entries belong here only after a skill has been used on at least two projects with consistent results. Per-skill detail files live under `skills/`.
