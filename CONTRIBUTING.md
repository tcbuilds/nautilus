# Contributing

Nautilus is a public SDLC playbook for AI-augmented software development. Contributions should improve the workflow, templates, standards, or documentation without adding project-specific private context.

## What belongs here

- Workflow guidance that has worked across more than one project.
- Reusable templates for planning, implementation, operations, or retrospectives.
- Agent and skill documentation that can be used without private credentials or local paths.
- Corrections that make the playbook clearer, safer, or easier to adopt.

## Before opening a pull request

Run these checks locally:

```bash
rtk git diff --check
rtk rg -n "secret|token|password|api_key|private|/home/|~/.claude" .
```

Preview edited Markdown and verify relative links. If a change affects a template, copy the template mentally into a new project and confirm the instructions still make sense outside this repo.

## Writing standards

Use concise Markdown, descriptive headings, and examples where they reduce ambiguity. Keep workflow pages skim-readable. If a section becomes long, split it into a focused document instead of growing one page indefinitely.

Avoid private references, customer names, internal hostnames, local machine paths, API keys, screenshots with secrets, or personal-only process assumptions.

## Commit style

Use Conventional Commits when practical:

```bash
docs(workflow): clarify roadmap task shape
feat(templates): add release checklist template
fix(templates): correct CI indentation
chore(repo): add open-source metadata
```

Commits should explain why the change exists. Do not add `Co-Authored-By` trailers for AI assistants.

## Pull request checklist

- Summary explains purpose and scope.
- Changed files are listed or obvious from the PR.
- Validation steps are included.
- Security or sanitization considerations are called out when relevant.
