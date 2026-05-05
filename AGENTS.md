# Repository Guidelines

## Project Structure & Module Organization

This is a documentation and workflow playbook repo, not an application. Keep contributions in Markdown or template files unless explicitly discussed.

- `README.md` gives the public overview and canonical repo map.
- `CLAUDE.md` contains repo-specific agent/editor instructions.
- `workflow/` holds phase docs, ordered by numeric prefixes such as `00-discovery.md`.
- `templates/` contains reusable project templates, including `templates/language-rules/`.
- `skills/`, `agents/`, and `examples/` hold short index-style docs and future examples.
- `token-economy.md`, `skills-index.md`, and `agents-index.md` are cross-cutting references.

## Build, Test, and Development Commands

There is no build system, package manager, or app runtime in this repo. Useful local checks:

- `rtk rg "term" .` searches docs quickly.
- `rtk find . -maxdepth 2 -type f` checks file placement.
- `rtk git diff --check` catches trailing whitespace and patch formatting issues.
- `rtk git status --short` reviews changed files before commit.

Preview Markdown in your editor before opening a PR, especially after changing links, tables, or templates.

## Coding Style & Naming Conventions

Use concise Markdown with clear headings, short paragraphs, and actionable bullets. Preserve the repo's public-facing tone: professional, portable, and free of private project details.

Name workflow files with an ordering prefix and descriptive slug, for example `04-build.md`. Use lowercase kebab-case for new Markdown files. Templates should end in `-template.md` when they are meant to be copied into other projects.

## Testing Guidelines

No automated test suite exists. Validate documentation changes manually:

- Check relative links resolve from the edited file.
- Confirm examples are copy-paste safe.
- Keep workflow docs skim-readable; split long additions instead of making one dense page.
- For YAML templates, preserve indentation and run a syntax check if available in your editor.

## Commit & Pull Request Guidelines

Git history uses Conventional Commits, for example `docs(token-economy): ...`, `feat: ...`, `fix(templates): ...`, and `chore(workflow): ...`. Prefer a scoped type when the change touches one area.

Commits should explain why the change exists, not only what changed. Do not add `Co-Authored-By` lines for Claude, AI, or any AI assistant.

PRs should include a short summary, changed paths, validation performed, and any follow-up work. Include screenshots only when Markdown rendering or visual formatting matters.

## Security & Configuration Tips

This repo is public-facing. Do not commit credentials, private business context, client names, or machine-specific paths. Keep reusable playbook guidance generic enough for future projects to adopt cleanly.
