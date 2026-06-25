---
name: adr-risk-register
description: Create Architecture Decision Records and a lightweight risk register for consequential technical decisions. Use when choices affect security, compliance, architecture, operations, vendor lock-in, data handling, or delivery risk.
---

# ADR Risk Register

Document decisions and risks so future reviewers can see what was chosen, why, what was rejected, and what needs follow-up.

## When to invoke

Use for auth architecture, cloud/service selection, data storage, LLM/MCP use, compliance scope, deployment model, migrations, public release, vendor integrations, and major refactors.

## Process

1. Identify the decision or risk from the spec, diff, incident, or discussion.
2. Capture context and constraints.
3. List options considered.
4. Record the decision, consequences, and controls.
5. Add or update `docs/adr/NNNN-title.md` and `risk_register.md`.

## ADR template

```markdown
# ADR NNNN: Title

## Status
Proposed / Accepted / Superseded

## Context
What situation forces a decision?

## Decision
What are we choosing?

## Alternatives Considered
- Option A
- Option B

## Consequences
- Positive:
- Negative:
- Follow-up:

## Review Date
YYYY-MM-DD
```

## Risk register format

| ID | Risk | Impact | Likelihood | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|
| R-001 | Example risk | High | Medium | Concrete action | Role | Open |

## Guardrails

- Keep ADRs factual and concise.
- Do not use ADRs to justify decisions after the fact without naming the actual constraint.
- Risks need owners and mitigations; otherwise they are notes, not managed risks.
- Do not include private customer names, credentials, or controlled data.
