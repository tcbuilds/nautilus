# CLAUDE.md — nautilus repo

Instructions for Claude Code sessions working **on this repo specifically**.

## What this repo is

A documentation and playbook repo. There is no application code here, and there will not be. Every file is prose, template, or index. Treat any request to add executable code as a likely mistake — clarify before acting.

## Editing rules

- Edits should be content-focused: clarifying workflow, adding examples, refining templates, expanding the skills/agents indices as new ones prove themselves.
- Preserve the public-facing tone. No personal references, credentials, or project-specific business details that do not belong in a reusable public artifact.
- When adding new skills, agents, or examples, follow the existing naming and structure pattern. Each skill or agent gets its own short markdown file under `skills/` or `agents/`. Each example gets its own subdirectory under `examples/`.
- Workflow docs stay short and skim-readable. If a doc grows past ~60 seconds of reading, split it.

## Commit rules

- All commits must be clear, descriptive, and explain the *why* of the change, not just the *what*.
- **Never** add `Co-Authored-By` lines for Claude, AI, or any AI assistant. Hard rule.
- Verify changes render correctly (markdown previews, links resolve) before committing.

## Standards this playbook teaches

This repo captures project-portable AI-assisted engineering rules and teaches projects to adopt them. Key principles referenced throughout the workflow docs:

- **Orchestrator-only at the top level.** The user-facing Claude Code session never writes code, runs commands, or makes edits directly. All implementation work goes to specialized agents via the Agent tool.
- **Mandatory delegation.** Use specialized agents, never `general-purpose`. Always pass `model="opus"` on Agent calls.
- **No mock data, no testnet defaults.** Real implementations or nothing.
- **Comments above the code, never inline.**
- **Edit existing files when debugging** — don't create parallel copies.
- **Commit and push verified working changes** with descriptive messages.
- **Use systemctl for systemd services**, never raw kill/pkill.
- **Examine log snapshots**, don't follow logs in real time.

When extending this repo's content, make sure new prose stays consistent with these standards. The whole point is that the playbook reflects the standards faithfully so projects bootstrapped from it inherit them cleanly.
