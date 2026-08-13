<p align="center">
  <img src="nautilus.jpg" alt="Nautilus shell" width="320">
</p>

<h1 align="center">nautilus</h1>

<p align="center"><strong>AI-augmented SDLC playbook — idea → spec → standards → roadmap → ship.</strong></p>

Nautilus is a reusable software delivery playbook for developers who use AI as an engineering accelerator without lowering the bar for planning, review, testing, incident response, or documentation. It turns loose product ideas into scoped specs, implementation plans, standards, and shipping routines that can be reused across projects.

## Why this exists

AI-assisted development is still software development. Nautilus makes that visible: every project starts with a written spec, adopts coding standards, breaks work into reviewable increments, validates changes, and records lessons after shipping. The goal is not to replace engineering judgment with prompts; the goal is to make AI-assisted work auditable, repeatable, and easier to improve.

## The Workflow

1. **[Discovery](workflow/00-discovery.md)** — Long-form ideation on claude.ai web. Output: `mvp.md` or `idea.md`.
2. **[Spec Refinement](workflow/01-spec-refinement.md)** — `/refine-spec` interrogates the draft and tightens it.
3. **[Init](workflow/02-init.md)** — `/init` generates a project-level `CLAUDE.md` rooted in the standards.
4. **[Roadmap](workflow/03-roadmap.md)** — `/roadmap` produces `implementation_plan.md` with phased checkboxes.
5. **[Build](workflow/04-build.md)** — use the active harness's native orchestrator: `/claude-build` in Claude Code or `/skill:pi-implement` in Pi.
6. **[Incident Response](workflow/05-incident-response.md)** — Severity ladder, mitigation discipline, and blameless postmortems for when production breaks.
7. **[Retrospective](workflow/06-retrospective.md)** — Per-phase and end-of-project retros with a DORA scoreboard, feeding lessons back into the playbook.
8. **[Maintaining the Playbook](workflow/07-maintaining-the-playbook.md)** — `/nautilus-sync` promotes mature skills and agents into this repo with sanitization.

## Cross-cutting

- **[Token Economy](token-economy.md)** — `caveman` mode and `rtk` cut token spend across every phase. Foundational infrastructure for any long-running Claude Code workflow.
- **[Secure Delivery Pack](SECURE_DELIVERY_PACK.md)** — skills, templates, and agent roles for enterprise or compliance-sensitive delivery.
- **[LGTM](https://github.com/tcbuilds/lgtm)** — a Rust binary that checks agent edits, blocks unresolved policy violations before an agent can call a task complete, and records what was verified. The enforcement layer beneath the review gate.

## Quickstart

### Install project standards

Bootstrap the cross-language baseline plus per-language pattern files into any project with a single command:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install.sh | sh
```

That writes `.claude/rules/standards.md` and
`.claude/rules/patterns/{rust,python,typescript}.md` (plus the patterns
`README.md`) into the current directory. Claude loads `standards.md` every
session and selects the pattern files through their `paths:` frontmatter.

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
mkdir -p .claude/rules/patterns
cp nautilus-main/templates/claude-rules/standards.md .claude/rules/
cp nautilus-main/templates/claude-rules/patterns/README.md .claude/rules/patterns/
cp nautilus-main/templates/claude-rules/patterns/rust.md .claude/rules/patterns/
rm -r nautilus-main
```

Swap `rust.md` for `python.md` or `typescript.md` (or copy multiple) as needed.

### Install user-level tooling

Sync the playbook's sanitized Claude Code skills and agents into `$HOME/.claude/` so they auto-load in every session:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
```

That writes each skill into `$HOME/.claude/skills/<skill-name>/` and each agent into `$HOME/.claude/agents/<agent-name>.md`. Defaults install everything available; existing files are overwritten (sync semantics).

Install the Pi-native implementation and review skills into Pi's shared Agent Skills directory:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- \
  --skills pi-implement,pi-review --agents none --dest "$HOME/.agents"
```

Pi discovers `$HOME/.agents/skills/` globally. Invoke them as `/skill:pi-implement` and `/skill:pi-review`. They require `pi-subagents` 0.46.0 or newer; they use native workers, reviewers, managed worktrees, retained runs, and acceptance evidence instead of invoking an external agent CLI.

Filter by name or opt out of clobbering:

```sh
# Specific skills only
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- --skills refine-spec,build

# Specific agents only
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- --agents git-platform-engineer

# Refuse to overwrite anything that already exists in ~/.claude/
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- --no-overwrite

# Different destination root
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- --dest /tmp/fresh-claude

# Pi-native skills only
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- \
  --skills pi-implement,pi-review --agents none --dest "$HOME/.agents"
```

See `sh install-tools.sh --help` for the full flag list (`--skills`, `--agents`, `--dest`, `--no-overwrite`, `--ref`).

The skill and agent payload fills out as artifacts mature in the playbook. In early phases the installer may report "no skills available" or "no agents available" and exit cleanly — that is expected.

If you would rather not pipe `curl` to `sh`, do it manually with the tarball:

```sh
curl -L https://github.com/tcbuilds/nautilus/archive/main.tar.gz | tar xz
mkdir -p ~/.claude/skills ~/.claude/agents
# Copy each skill directory you want (skip the framing README.md):
cp -R nautilus-main/skills/<skill-name> ~/.claude/skills/
# Copy each agent file you want (skip the framing README.md):
cp nautilus-main/agents/<agent-name>.md ~/.claude/agents/
rm -rf nautilus-main
```

The repo-level `skills/README.md` and `agents/README.md` are framing docs about the convention — they are not loadable artifacts, so leave them out of `~/.claude/`.

## Repo Layout

```
nautilus/
├── README.md
├── install.sh                      # project-level bootstrap installer
├── install-tools.sh                # user-level skills + agents installer
├── .github/                        # PR and issue templates
├── AGENTS.md                       # contributor guide for AI agents and maintainers
├── CONTRIBUTING.md                 # contribution and validation workflow
├── SECURITY.md                     # vulnerability and sensitive-data reporting
├── CODE_OF_CONDUCT.md
├── LICENSE
├── SECURE_DELIVERY_PACK.md
├── OPEN_SOURCE_CHECKLIST.md
├── CLAUDE.md                       # repo-level orchestrator instructions
├── workflow/
│   ├── 00-discovery.md
│   ├── 01-spec-refinement.md
│   ├── 02-init.md
│   ├── 03-roadmap.md
│   ├── 04-build.md
│   ├── 05-incident-response.md
│   ├── 06-retrospective.md
│   └── 07-maintaining-the-playbook.md
├── templates/
│   ├── claude-rules/
│   │   ├── standards.md
│   │   └── patterns/
│   │       ├── README.md
│   │       ├── rust.md
│   │       ├── python.md
│   │       └── typescript.md
│   ├── CLAUDE.secure-delivery-template.md
│   ├── AGENTS.secure-delivery-template.md
│   ├── mvp-template.md
│   ├── idea-template.md
│   ├── CLAUDE.md.template
│   ├── adr-template.md
│   ├── runbook-template.md
│   ├── postmortem-template.md
│   ├── migration-pattern.md
│   └── ci-pipeline.yml
├── skills/
│   ├── README.md
│   ├── pi-implement/
│   │   ├── SKILL.md
│   │   └── references/plan-orchestration.md
│   ├── pi-review/
│   │   ├── SKILL.md
│   │   └── assets/findings-ledger.schema.json
│   └── <skill-name>/SKILL.md
├── agents/
│   ├── README.md
│   └── <agent-name>.md
├── examples/
│   ├── README.md
│   └── example-project/
├── skills-index.md
├── agents-index.md
└── token-economy.md
```

## How to use this repo

- **Bootstrap a new project** with the [Quickstart](#quickstart) one-liner — it drops the always-loaded standards and path-scoped language patterns into `.claude/rules/`. For other templates (`CLAUDE.md.template`, `mvp-template.md`, `idea-template.md`), copy them in by hand from `templates/`.
- **Reference the workflow docs** in order — each phase has a single short page describing what to run, what the output is, and when to move on.
- **Contribute back.** Living asset, not artifact. Every project that uses this playbook updates the playbook in the same PR — new lessons, new skills, new agent patterns. The shell grows with each chamber.
- **Pull this repo** as a reference inside future Claude Code sessions when you need the canonical version of the workflow.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for validation steps, documentation standards, and review expectations.

## License

MIT. See [LICENSE](LICENSE).
