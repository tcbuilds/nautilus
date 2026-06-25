---
name: repo-orientation
description: Build an onboarding-quality breakdown of an existing repository. Use when asked to explain a shared repo, map architecture, identify build/test/deploy behavior, understand CI/CD, or create repo_orientation.md for safe handoff.
---

# Repo Orientation

Create a practical, evidence-backed orientation document for an existing repository. The output should help a developer understand what the repo does, how it is built, how it is tested, how it deploys, and how to make changes safely.

## When to invoke

Use for shared repos, inherited codebases, onboarding, audit prep, production handoff, or before planning work in an unfamiliar project.

## Process

### 1. Read repo-level guidance

Read any present files:

- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `codingStandards.md`
- `docs/`
- `implementation_plan.md`

### 2. Inspect project shape

Identify:

- Primary language/framework/runtime.
- Main source directories.
- App/library/CLI entry points.
- Package/build files: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Makefile`, `justfile`, `taskfile.yml`, etc.
- Configuration files and environment examples.
- Test directories and fixtures.
- Database/migration directories.
- Docker, Kubernetes, Terraform, Helm, systemd, or other deployment files.
- CI/CD files: `.gitlab-ci.yml`, `.github/workflows/`, or other platform config.

### 3. Determine commands

Extract actual repo commands from evidence. Do not invent commands.

Capture:

- setup/install
- local development
- build/package
- test
- lint/typecheck/format
- database/migration
- deploy/release
- smoke/health checks

If command evidence is missing, write `Not documented` and list the file or owner needed to confirm.

### 4. Map architecture and behavior

Explain:

- What the repo is for.
- Who or what uses it.
- Major modules and responsibilities.
- Request/job/CLI/data flow.
- External systems and integrations.
- Data storage and config/secrets behavior.
- Runtime/deployment model.
- Observability: logs, metrics, traces, alerts, dashboards, runbooks.

### 5. Identify safety notes

Call out:

- High-risk files or modules.
- Sensitive data handling.
- Required review gates.
- Deployment or rollback risks.
- Test gaps and undocumented commands.
- Platform-specific workflow: GitLab merge requests/pipelines or GitHub pull requests/Actions.

## Output

Write `repo_orientation.md` at the repo root unless the user asks for chat-only output.

Use this structure:

```markdown
# Repo Orientation

## Purpose
## Quick Start
## Repository Map
## Main Entry Points
## Architecture
## Build and Local Development
## Test and Quality Gates
## Deployment and Release Behavior
## Configuration and Secrets
## Data and External Integrations
## Observability and Operations
## Safe Change Workflow
## Known Gaps and Questions
```

## Guardrails

- Evidence first. Prefer paths and commands found in the repo over assumptions.
- Do not add new tooling or process recommendations unless clearly marked as a gap.
- Do not expose secrets or controlled data in the orientation.
- Use GitLab terminology for GitLab repos and GitHub terminology for GitHub repos.
- If deployment behavior is unclear, say so. Do not infer production paths from unrelated files.
- Keep the document useful for a new developer: concrete commands, paths, and risks beat abstract architecture prose.
