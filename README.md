# nautilus

**Workflow playbook — idea → spec → CLAUDE.md → roadmap → ship.**

A nautilus shell grows by adding chambers, each one larger than the last by the golden ratio. Every project is a new chamber. The playbook is the shell. This repo canonizes the workflow that turns ideas into shipped code through Claude Code, so each new chamber can be built on the same proven structure rather than from scratch.

## The Workflow

1. **[Discovery](workflow/00-discovery.md)** — Long-form ideation on claude.ai web. Output: `mvp.md` or `idea.md`.
2. **[Spec Refinement](workflow/01-spec-refinement.md)** — `/refine-spec` interrogates the draft and tightens it.
3. **[Init](workflow/02-init.md)** — `/init` generates a project-level `CLAUDE.md` rooted in the standards.
4. **[Roadmap](workflow/03-roadmap.md)** — `/roadmap` produces `implementation_plan.md` with phased checkboxes.
5. **[Build](workflow/04-build.md)** — `/build` dispatches specialized agents to execute the plan.

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
│   └── 04-build.md
├── templates/
│   ├── codingStandards.md
│   ├── mvp-template.md
│   ├── idea-template.md
│   └── CLAUDE.md.template
├── skills/
│   └── README.md
├── agents/
│   └── README.md
├── examples/
│   └── README.md
├── skills-index.md
└── agents-index.md
```

## How to use this repo

- **Bootstrap a new project** by copying the relevant templates (`codingStandards.md`, `CLAUDE.md.template`, `mvp-template.md` or `idea-template.md`) into the project root.
- **Reference the workflow docs** in order — each phase has a single short page describing what to run, what the output is, and when to move on.
- **Contribute back.** Living asset, not artifact. Every project that uses this playbook updates the playbook in the same PR — new lessons, new skills, new agent patterns. The shell grows with each chamber.
- **Pull this repo** as a reference inside future Claude Code sessions when you need the canonical version of the workflow.

## Status

Private. Will flip public after maturity.
