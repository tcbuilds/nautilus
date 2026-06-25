---
name: codex-review
description: Run a second-pass Codex review over changed files and produce severity-ordered findings. Use after implementation, before marking tasks complete, before merge requests/pull requests, or when a skeptical review is needed for correctness, security, edge cases, and missing tests.
---

# Codex Review

Use Codex as an independent review gate after implementation work. The goal is not style commentary; the goal is to catch correctness, security, edge-case, data-handling, and test gaps before work is marked done.

## When to invoke

- After a task in `implementation_plan.md` is implemented.
- Before a merge request or pull request is opened.
- Before release-readiness for risky changes.
- After a fix agent claims it resolved review findings.
- When the user asks for a second-pass review.

## Inputs

The user should provide changed files or a diff. If no files are listed, inspect `git status --short` and review changed tracked/untracked files that are relevant to the task. Do not review unrelated local changes.

## Process

1. Identify files to review.
2. Run Codex review using the local Codex CLI when available.
3. Parse findings by severity: Critical, High, Medium, Low.
4. Report findings first, ordered by severity.
5. Recommend fixes for Critical and High findings before task completion.
6. If no issues are found, say so and state residual risk or test gaps.

## Command pattern

```bash
codex exec --full-auto --skip-git-repo-check -o /tmp/codex-review.md \
  "Review these files for correctness, security, and edge cases. Files: <files>. Write findings ordered by severity (Critical > High > Medium > Low)."
```

If `codex` is unavailable, perform a manual review with the same output format and state that the Codex CLI was not run.

## Output format

```markdown
# Codex Review

## Findings

### Critical
- None

### High
- None

### Medium
- [file:line] Finding, impact, fix.

### Low
- [file:line] Finding, impact, fix.

## Verification
- Command run or manual-review fallback.

## Gate Decision
PASS / BLOCKED
```

## Gate rules

- Any Critical or High finding blocks task completion.
- Medium and Low findings should be reported but do not block unless the user or project policy says otherwise.
- Do not mark a task complete until Critical and High findings are fixed or explicitly accepted by the user.
- Do not paste secrets or controlled data into the Codex prompt or output.
- Delete temporary review output files when done unless the user asks to keep them.
