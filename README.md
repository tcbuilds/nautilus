# nautilus

**AI-augmented SDLC playbook — idea -> spec -> standards -> roadmap -> ship.**

Nautilus is a reusable software delivery playbook for developers who use AI as an engineering accelerator without lowering the bar for planning, review, testing, incident response, or documentation. It turns loose product ideas into scoped specs, implementation plans, standards, and shipping routines that can be reused across projects.

## Why this exists

AI-assisted development is still software development. Nautilus makes that visible: every project starts with a written spec, adopts coding standards, breaks work into reviewable increments, validates changes, and records lessons after shipping. The goal is not to replace engineering judgment with prompts; the goal is to make AI-assisted work auditable, repeatable, and easier to improve.

## The Workflow

1. **[Discovery](workflow/00-discovery.md)** — Long-form ideation on claude.ai web. Output: `mvp.md` or `idea.md`.
2. **[Spec Refinement](workflow/01-spec-refinement.md)** — `/refine-spec` interrogates the draft and tightens it.
3. **[Init](workflow/02-init.md)** — `/init` generates a project-level `CLAUDE.md` rooted in the standards.
4. **[Roadmap](workflow/03-roadmap.md)** — `/roadmap` produces `implementation_plan.md` with phased checkboxes.
5. **[Build](workflow/04-build.md)** — `/build` dispatches specialized agents to execute the plan.
6. **[Incident Response](workflow/04.8-incident-response.md)** — Severity ladder, mitigation discipline, and blameless postmortems for when production breaks.
7. **[Retrospective](workflow/06-retrospective.md)** — Per-phase and end-of-project retros with a DORA scoreboard, feeding lessons back into the playbook.
8. **[Maintaining the Playbook](workflow/08-maintaining-the-playbook.md)** — `/nautilus-sync` promotes mature skills and agents into this repo with sanitization.

## Cross-cutting

- **[Token Economy](token-economy.md)** — `caveman` mode and `rtk` cut token spend across every phase. Foundational infrastructure for any long-running Claude Code workflow.

## Quickstart

Bootstrap the cross-language baseline plus per-language pattern files into any project with a single command:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install.sh | sh
```

That writes `./codingStandards.md` and `./.claude/rules/{rust,python,typescript}-patterns.md` (plus the rules `README.md`) into the current directory.

Filter by language:

```sh
# Rust only
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install.sh | sh -s -- --lang rust

# Polyglot subset
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install.sh | sh -s -- --lang rust,typescript

# Different target directory; overwrite if files already exist
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install.sh | sh -s -- --dest ./myproj --force
```

See `sh install.sh --help` for the full flag list (`--lang`, `--dest`, `--force`, `--ref`).

If you would rather not pipe `curl` to `sh`, do it manually with the tarball:

```sh
curl -L https://github.com/tcbuilds/nautilus/archive/main.tar.gz | tar xz
mkdir -p .claude/rules
cp nautilus-main/templates/codingStandards.md ./
cp nautilus-main/templates/language-rules/README.md .claude/rules/
cp nautilus-main/templates/language-rules/rust-patterns.md .claude/rules/
rm -rf nautilus-main
```

Swap `rust-patterns.md` for `python-patterns.md` or `typescript-patterns.md` (or copy multiple) as needed.

## Repo Layout

```
nautilus/
├── README.md
├── install.sh                      # one-shot bootstrap installer
├── .github/                        # PR and issue templates
├── AGENTS.md                       # contributor guide for AI agents and maintainers
├── CONTRIBUTING.md                 # contribution and validation workflow
├── SECURITY.md                     # vulnerability and sensitive-data reporting
├── CODE_OF_CONDUCT.md
├── LICENSE
├── OPEN_SOURCE_CHECKLIST.md
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
│   ├── README.md
│   └── example-project/
├── skills-index.md
├── agents-index.md
└── token-economy.md
```

## How to use this repo

- **Bootstrap a new project** with the [Quickstart](#quickstart) one-liner — it drops `codingStandards.md` and the language pattern files into the right places automatically. For other templates (`CLAUDE.md.template`, `mvp-template.md`, `idea-template.md`), copy them in by hand from `templates/`.
- **Reference the workflow docs** in order — each phase has a single short page describing what to run, what the output is, and when to move on.
- **Contribute back.** Living asset, not artifact. Every project that uses this playbook updates the playbook in the same PR — new lessons, new skills, new agent patterns. The shell grows with each chamber.
- **Pull this repo** as a reference inside future Claude Code sessions when you need the canonical version of the workflow.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for validation steps, documentation standards, and review expectations.

## License

MIT. See [LICENSE](LICENSE).
