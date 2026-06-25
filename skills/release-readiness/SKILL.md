---
name: release-readiness
description: Run a pre-merge or pre-deploy release readiness check. Use before shipping production changes, public releases, enterprise deliveries, compliance-sensitive releases, or customer-facing milestones. Produces release_readiness.md.
---

# Release Readiness

Create a concrete go/no-go checklist for a release. Focus on evidence, rollback, testing, security, and operational readiness.

## When to invoke

Use before merging a large merge request or pull request, tagging a release, deploying to production, publishing an open-source repo, or delivering to a customer environment.

## Process

1. Identify release scope and changed files.
2. Verify tests, lint, build, migrations, docs, and security checks.
3. Check operational readiness: rollback, feature flags, logs, metrics, alerts, runbooks.
4. Check release artifacts: changelog, version tag, SBOM if applicable, license/dependency review, deployment notes.
5. Write `release_readiness.md` with go/no-go status.

## Checklist

- [ ] Scope and owner are clear
- [ ] Tests relevant to changed behavior pass
- [ ] Security-sensitive changes reviewed
- [ ] Data migration or rollback plan exists if needed
- [ ] Secrets and configuration changes documented
- [ ] Dependencies reviewed for license and vulnerability risk
- [ ] User-facing docs or release notes updated
- [ ] Monitoring/logging sufficient for the change
- [ ] Rollback path is known and tested when practical
- [ ] Open risks are accepted by an owner

## Output format

```markdown
# Release Readiness

**Status:** Go / No-Go / Go with accepted risk

## Scope
## Validation Performed
## Risks and Mitigations
## Rollback Plan
## Open Questions
## Final Decision
```

## Guardrails

- Do not approve a release when validation is missing; mark `No-Go` or `Go with accepted risk`.
- Do not invent passing tests. Record commands actually run or state `not run`.
- Keep release notes free of secrets, controlled data, and private customer context.
