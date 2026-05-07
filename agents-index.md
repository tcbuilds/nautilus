# Agents Index

Quick reference for the specialized Claude Code agents most relevant to the nautilus workflow. The full list of available agents lives in the user's global `CLAUDE.md`; this index highlights the ones that matter most across the discovery → ship pipeline.

| Agent | Specialization | When to delegate |
|---|---|---|
| `github-master` | Git operations, GitHub Actions, CI/CD, branch protection, repo lifecycle. | Repo setup, releases, branch protection rules, workflow files, anything involving `gh` or `git` at scale. |
| `Explore` | Fast codebase search and orientation. (Claude Code built-in, not shipped here.) | "Where is X?" / "How does Y work?" questions. First stop when entering an unfamiliar repo. |
| `python-core-engineer` | Core Python infrastructure, asyncio, design patterns, refactoring. | Architecting backend modules, async/concurrent code, structural Python work. |
| `performance-optimizer` | Profiling, bottleneck identification, latency reduction. | Slow code, hot paths, throughput problems, "make this faster" requests. |

The full agent list lives in the user's global `CLAUDE.md`. This index intentionally stays short and focused on the workflow-critical specialists. Per-agent detail files live under `agents/` as they get documented.
