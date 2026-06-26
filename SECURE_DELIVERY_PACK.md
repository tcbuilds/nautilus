# Secure Delivery Pack

This pack is a small, public-safe set of skills, templates, and agent roles for AI-augmented software work in enterprise or compliance-sensitive repositories.

## Install

Install the secure-delivery skills and agent roles:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh -s -- \
  --skills warmup,refine-spec,roadmap,build,repo-orientation,codex-review,hardening-audit,compliance-review,data-classification,secure-code-review,release-readiness,adr-risk-register \
  --agents git-platform-engineer,repo-investigator,security-reviewer,test-engineer,technical-writer,compliance-reviewer
```

Install all Nautilus tools:

```sh
curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
```

## Recommended skills

- `/refine-spec` - turns rough requirements into auditable specs.
- `/warmup` - loads repo-local rules, recent history, current state, and safe next steps.
- `/roadmap` - creates traceable implementation plans.
- `/build` - executes planned tasks through specialized agents.
- `/repo-orientation` - creates onboarding-quality repo breakdowns for shared codebases.
- `/codex-review` - runs a second-pass Codex review and blocks Critical/High findings.
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
- Test engineer: regression coverage and verification.
- Technical writer: user-facing and audit-facing documentation.
- Compliance reviewer: control evidence, POA&M candidates, and governance gaps.
- Git platform engineer: GitLab/GitHub-neutral repo, CI/CD, merge request, and release operations.

## GitLab note

For GitLab environments, use `git-platform-engineer`, not `github-master`. The `github-master` agent remains available for GitHub-hosted repositories and GitHub-specific features, but secure-delivery guidance should use platform-neutral language unless the repository is actually on GitHub.

## Guardrails

- Do not paste controlled data, customer names, secrets, or internal hostnames into prompts or generated docs.
- Treat model prompts, MCP outputs, logs, traces, and screenshots as data stores.
- Keep broad shell, filesystem, network, browser, and deploy tools disabled unless the task requires them.
- Separate local/dev agent configs from customer or production environments.
- Human owners make final compliance, legal, release, and data-classification decisions.
