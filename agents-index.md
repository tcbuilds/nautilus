# Agents Index

Quick reference for the specialized Claude Code agents most relevant to the nautilus workflow. Loadable agent files live under `agents/`.

| Agent | Specialization | When to delegate |
|---|---|---|
| `git-platform-engineer` | GitLab, GitHub, and generic Git repository operations, CI/CD, branch protection, and release workflows. | Default repo-ops agent, especially when the host may be GitLab or the work needs platform-neutral language. |
| `github-master` | GitHub-specific operations, GitHub Actions, GitHub security features, and `gh` workflows. | Use only for GitHub-hosted repos or tasks that explicitly require GitHub platform features. |
| `Explore` | Fast codebase search and orientation. (Claude Code built-in, not shipped here.) | "Where is X?" / "How does Y work?" questions. First stop when entering an unfamiliar repo. |
| `repo-investigator` | Read-only repository orientation and subsystem mapping. | Use before implementation in unfamiliar codebases or compliance-sensitive environments where traceability matters. |
| `security-reviewer` | Security-focused code, architecture, MCP/tooling, CI, and deployment review. | Auth, data exposure, injection, secrets, supply-chain, and agent-tool risk reviews. |
| `red-team-analyst` | Defensive adversarial review of plans, architecture, auth, APIs, data handling, MCP/tooling, and release risk. | Use before high-risk implementation or delivery to surface failure modes and mitigations. |
| `test-engineer` | Verification planning and targeted regression coverage. | Feature validation, bug regressions, release readiness, and unclear test failures. |
| `technical-writer` | README, runbook, ADR, release note, and audit-friendly docs. | Public docs, internal evidence, sanitized explanations, and operational documentation. |
| `compliance-reviewer` | Control evidence, data handling, POA&M candidates, and governance gaps. | Enterprise or regulated customer review preparation. |
| `python-core-engineer` | Core Python infrastructure, asyncio, design patterns, refactoring. | Architecting backend modules, async/concurrent code, structural Python work. |
| `typescript-core-engineer` | TypeScript/JavaScript modules, frontend/backend TS, build tooling, and type-safety reviews. | TS/JS/React/Node/Vite work, strict typing, async flow bugs, and package scripts. |
| `rust-systems-engineer` | Rust services, CLIs, async Rust, FFI, performance, and memory-safety review. | Rust implementation, unsafe-code review, ownership/lifetime issues, Cargo/tests/benchmarks. |
| `sql-state-architect` | Database design, SQL performance, migrations, transactions, and state boundaries. | Schema, query, index, migration, persistence, and data-integrity work. |
| `linux-sre-master` | Linux services, systemd, logs, deployment, observability, and production hardening. | Runtime, deploy, service, resource, backup, and operational reliability work. |
| `network-diagnostics` | DNS, TLS, HTTP, WebSocket, firewall, proxy, latency, and connectivity troubleshooting. | Network errors, timeouts, disconnects, TLS failures, and egress/proxy issues. |
| `performance-optimizer` | Profiling, bottleneck identification, latency reduction. | Slow code, hot paths, throughput problems, "make this faster" requests. |

This index intentionally stays short and focused on workflow-critical specialists. Per-agent detail files live under `agents/`.
