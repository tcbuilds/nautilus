# Agents Index

Quick reference for the specialized Claude Code agents most relevant to the nautilus workflow. Loadable agent files live under `agents/`.

| Agent | Specialization | When to delegate |
|---|---|---|
| `github-master` | Git operations, GitHub Actions, CI/CD, branch protection, repo lifecycle. | Repo setup, releases, branch protection rules, workflow files, anything involving `gh` or `git` at scale. |
| `Explore` | Fast codebase search and orientation. (Claude Code built-in, not shipped here.) | "Where is X?" / "How does Y work?" questions. First stop when entering an unfamiliar repo. |
| `repo-investigator` | Read-only repository orientation and subsystem mapping. | Use before implementation in unfamiliar codebases or regulated environments where traceability matters. |
| `security-reviewer` | Security-focused code, architecture, MCP/tooling, CI, and deployment review. | Auth, data exposure, injection, secrets, supply-chain, and agent-tool risk reviews. |
| `test-engineer` | Verification planning and targeted regression coverage. | Feature validation, bug regressions, release readiness, and unclear test failures. |
| `technical-writer` | README, runbook, ADR, release note, and audit-friendly docs. | Public docs, internal evidence, sanitized explanations, and operational documentation. |
| `compliance-reviewer` | Control evidence, data handling, POA&M candidates, and governance gaps. | Public-sector, enterprise, or regulated customer review preparation. |
| `python-core-engineer` | Core Python infrastructure, asyncio, design patterns, refactoring. | Architecting backend modules, async/concurrent code, structural Python work. |
| `performance-optimizer` | Profiling, bottleneck identification, latency reduction. | Slow code, hot paths, throughput problems, "make this faster" requests. |

This index intentionally stays short and focused on workflow-critical specialists. Per-agent detail files live under `agents/`.
