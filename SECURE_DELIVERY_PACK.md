# Secure Delivery Pack

This pack is a small, public-safe set of skills, templates, and agent roles for AI-augmented software work in enterprise or compliance-sensitive repositories.

## Install

Install the secure-delivery skills and agent roles:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- \
  --skills warmup,handoff,refine-spec,roadmap,claude-build,repo-orientation,codex-review,codex-implement,hardening-audit,compliance-review,data-classification,secure-code-review,release-readiness,adr-risk-register \
  --agents git-platform-engineer,repo-investigator,security-reviewer,red-team-analyst,test-engineer,technical-writer,compliance-reviewer,python-core-engineer,typescript-core-engineer,rust-systems-engineer,sql-state-architect,linux-sre-master,network-diagnostics,performance-optimizer
```

Install all Nautilus tools:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
```

## Prerequisites

Only the Codex-backed skills need external tooling. `/warmup`, `/handoff`, `/roadmap`, `/adr-risk-register`, and the rest of the pack have no external dependency.

Required for `/codex-review` and `/codex-implement`:

- Codex CLI, installed and authenticated. The profile mechanism below was verified against codex-cli 0.146.0; `-p` semantics and the strict-config key set are version-dependent.
- Python with the `jsonschema` package, if you want to validate the shipped JSON schemas locally.

Optional:

- `rtk` - the skills' command examples wrap calls in `rtk proxy`. Both skills document the no-rtk fallback (drop the wrapper and report it), so this is optional.
- CodeGraph - both skills use `codegraph explore` for structural questions when a `.codegraph/` index exists, and both document a read-only fallback when it does not.

**Codex profiles.** `install-tools.sh` copies each skill directory into `$DEST/skills/<name>/`, so a skill's `assets/` travels with it. Codex does not read profiles from there: `codex exec -p <name>` resolves `${CODEX_HOME:-$HOME/.codex}/<name>.config.toml` and nothing else. Install the profiles separately or every documented codex command in both skills fails with a missing-profile error.

Automatic - pass `--codex-profiles` to the installer. After installing the selected skills it copies every installed skill's `assets/*.config.toml` into `${CODEX_HOME:-$HOME/.codex}/`, never overwriting an existing profile (existing ones are reported as skipped), and prints a written/skipped summary. The default is off, so the flag must be passed explicitly.

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- \
  --skills warmup,handoff,refine-spec,roadmap,claude-build,repo-orientation,codex-review,codex-implement,hardening-audit,compliance-review,data-classification,secure-code-review,release-readiness,adr-risk-register \
  --agents git-platform-engineer,repo-investigator,security-reviewer,red-team-analyst,test-engineer,technical-writer,compliance-reviewer,python-core-engineer,typescript-core-engineer,rust-systems-engineer,sql-state-architect,linux-sre-master,network-diagnostics,performance-optimizer \
  --codex-profiles
```

Manual - copy the profiles out of the installed skill directories. Unlike `--codex-profiles`, this overwrites profiles that already exist.

```sh
mkdir -p "${CODEX_HOME:-$HOME/.codex}"
cp "$HOME"/.claude/skills/codex-*/assets/*.config.toml "${CODEX_HOME:-$HOME/.codex}/"
```

**Preflight.** Verify one profile before relying on it.

- Preflight the installed file, not `codex ... --help`; help does not load the profile.
- A profile that fails `--strict-config` aborts before any model call.
- The shipped profiles deliberately carry no `name` or `description` key. Codex 0.146.0 rejects both as unknown configuration fields under `--strict-config`, so an editor adding them back would break every launch.

## Recommended skills

- `/refine-spec` - turns rough requirements into auditable specs.
- `/warmup` - loads repo-local rules, recent history, current state, and safe next steps.
- `/handoff` - writes resume state, validation, risks, and next steps for future sessions.
- `/roadmap` - creates traceable implementation plans.
- `/claude-build` - executes planned tasks through specialized agents behind an independent review gate.
- `/repo-orientation` - creates onboarding-quality repo breakdowns for shared codebases.
- `/codex-review` - runs a second-pass Codex review and blocks Critical/High findings.
- `/codex-implement` - executes one slice or an implementation-plan task, phase, or full plan through file-owned Luna workers in isolated worktrees; the parent verifies each slice and one independent Sol reviewer gates the integrated phase.
- `/hardening-audit` - checks production, LLM, MCP, API, and infrastructure hardening.
- `/compliance-review` - maps evidence and gaps for enterprise or regulated-environment readiness.
- `/data-classification` - identifies sensitive data and handling rules.
- `/secure-code-review` - reviews code for exploitable security defects.
- `/release-readiness` - creates go/no-go evidence before merge or deploy.
- `/adr-risk-register` - records decisions, tradeoffs, risks, and owners.

## Recommended templates

- `templates/CLAUDE.secure-delivery-template.md` - Claude Code project guidance for enterprise or compliance-sensitive repositories.
- `templates/AGENTS.secure-delivery-template.md` - Codex/agent guidance for enterprise or compliance-sensitive repositories.

## Recommended agent roles

- Repo investigator: read-only code orientation.
- Security reviewer: security-focused diff and architecture review.
- Red team analyst: defensive adversarial review of plans, threat models, APIs, auth, data, MCP/tooling, and release risk.
- Test engineer: regression coverage and verification.
- Technical writer: user-facing and audit-facing documentation.
- Compliance reviewer: control evidence, POA&M candidates, and governance gaps.
- Git platform engineer: GitLab/GitHub-neutral repo, CI/CD, merge request, and release operations.
- Python core engineer: Python services, scripts, async code, and backend modules.
- TypeScript core engineer: TypeScript/JavaScript, frontend/backend TS, and build tooling.
- Rust systems engineer: Rust services, CLIs, async Rust, FFI, and performance-sensitive code.
- SQL state architect: database schema, migrations, queries, indexes, and persistence boundaries.
- Linux SRE master: systemd, Linux services, deploy/runtime behavior, logs, and hardening.
- Network diagnostics: DNS, TLS, HTTP, WebSocket, proxy, firewall, and connectivity issues.
- Performance optimizer: profiling, bottleneck analysis, latency, and throughput work.

## GitLab note

For GitLab environments, use `git-platform-engineer`, not `github-master`. The `github-master` agent remains available for GitHub-hosted repositories and GitHub-specific features, but secure-delivery guidance should use platform-neutral language unless the repository is actually on GitHub.

## Guardrails

- Do not paste controlled data, customer names, secrets, or internal hostnames into prompts or generated docs.
- Treat model prompts, MCP outputs, logs, traces, and screenshots as data stores.
- Keep broad shell, filesystem, network, browser, and deploy tools disabled unless the task requires them.
- Separate local/dev agent configs from customer or production environments.
- Human owners make final compliance, legal, release, and data-classification decisions.
