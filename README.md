# nautilus

**Workflow playbook — idea → spec → CLAUDE.md → roadmap → ship.**

A nautilus shell grows by adding chambers, each one larger than the last by the golden ratio. Every project is a new chamber. The playbook is the shell. This repo canonizes the workflow that turns ideas into shipped code through Claude Code, so each new chamber can be built on the same proven structure rather than from scratch.

## The Workflow

1. **[Discovery](workflow/00-discovery.md)** — Long-form ideation on claude.ai web. Output: `mvp.md` or `idea.md`.
2. **[Spec Refinement](workflow/01-spec-refinement.md)** — `/refine-spec` interrogates the draft and tightens it.
3. **[Init](workflow/02-init.md)** — `/init` generates a project-level `CLAUDE.md` rooted in the standards.
4. **[Roadmap](workflow/03-roadmap.md)** — `/roadmap` produces `implementation_plan.md` with phased checkboxes.
5. **[Build](workflow/04-build.md)** — `/build` dispatches specialized agents to execute the plan.
6. **[Incident Response](workflow/04.8-incident-response.md)** — Solo-edition severity ladder, mitigation discipline, and blameless postmortems for when production breaks.
7. **[Retrospective](workflow/06-retrospective.md)** — Per-phase and end-of-project retros with a DORA scoreboard, feeding lessons back into the playbook.
8. **[Maintaining the Playbook](workflow/08-maintaining-the-playbook.md)** — `/nautilus-sync` promotes mature skills and agents from `~/.claude/` into this repo with sanitization.

## Cross-cutting

- **[Token Economy](token-economy.md)** — `caveman` mode and `rtk` cut token spend across every phase. Foundational infrastructure for any long-running Claude Code workflow.

## Repo Layout

```
nautilus/
├── README.md
├── CLAUDE.md                       # repo-level orchestrator instructions
├── workflow/
│   ├── 00-discovery.md
│   ├── 01-spec-refinement.md
│   ├── 02-init.md
│   ├── 03-roadmap.md
│   ├── 04-build.md
│   ├── 04.8-incident-response.md
│   ├── 06-retrospective.md
│   └── 08-maintaining-the-playbook.md
├── templates/
│   ├── codingStandards.md
│   ├── language-rules/
│   │   ├── README.md
│   │   ├── rust-patterns.md
│   │   ├── python-patterns.md
│   │   └── typescript-patterns.md
│   ├── mvp-template.md
│   ├── idea-template.md
│   ├── CLAUDE.md.template
│   ├── adr-template.md
│   ├── runbook-template.md
│   ├── postmortem-template.md
│   ├── migration-pattern.md
│   └── ci-pipeline.yml
├── skills/
│   └── README.md
├── agents/
│   └── README.md
├── examples/
│   └── README.md
├── skills-index.md
├── agents-index.md
└── token-economy.md
```

## How to use this repo

- **Bootstrap a new project** by copying the relevant templates (`codingStandards.md`, `CLAUDE.md.template`, `mvp-template.md` or `idea-template.md`) into the project root.
- **Per-language pattern templates** (`templates/language-rules/rust-patterns.md`, `templates/language-rules/python-patterns.md`, `templates/language-rules/typescript-patterns.md`) are starting points — copy the relevant one into a new project's `.claude/rules/` and trim or extend per project needs.
- **Reference the workflow docs** in order — each phase has a single short page describing what to run, what the output is, and when to move on.
- **Contribute back.** Living asset, not artifact. Every project that uses this playbook updates the playbook in the same PR — new lessons, new skills, new agent patterns. The shell grows with each chamber.
- **Pull this repo** as a reference inside future Claude Code sessions when you need the canonical version of the workflow.

## Status

Private. Will flip public after maturity.
