---
name: compliance-review
description: Review a project for public-sector and regulated-environment readiness. Use for NIST 800-171, CMMC, FedRAMP-style control awareness, audit evidence, SSP/POA&M preparation, and governance gaps. Produces compliance_report.md with findings, evidence, and next actions.
---

# Compliance Review

Review a repository for compliance readiness without claiming certification or replacing an assessor, ISSO, legal counsel, or security officer.

## When to invoke

Use when preparing software for regulated work, public-sector delivery, customer security review, CUI/PII handling, or an internal audit.

## Process

1. Identify scope: app type, data types, users, deployment, auth, dependencies, hosting, integrations.
2. Map likely control families: access control, audit logging, configuration management, identification/authentication, incident response, media/data protection, risk assessment, system integrity.
3. Inspect repository evidence: README, security policy, CI, tests, logging, auth, secrets handling, dependency management, deployment docs, ADRs, runbooks.
4. Separate facts from gaps. Do not infer compliance from intent.
5. Create `compliance_report.md`.

## Findings format

Each finding must include:

- Severity: Critical, High, Medium, Low, Informational
- Control area: e.g. Access Control, Audit Logging, Configuration Management
- Evidence: file path, command output, or explicit "not found"
- Risk: why it matters
- Remediation: concrete next step
- Owner: role or placeholder
- Status: Open, In Progress, Accepted, Closed

## Report outline

```markdown
# Compliance Review Report

## Scope
## Executive Summary
## Data Classification Assumptions
## Control Coverage Summary
## Findings
## Evidence Inventory
## POA&M Candidates
## Open Questions
```

## Guardrails

- Do not state that a system is "compliant" or "certified".
- Do not include secrets, private customer names, internal hostnames, or controlled data in the report.
- If CUI, export-controlled data, health data, financial data, or minors' data may be involved, flag for human owner review.
- Treat missing evidence as a gap, not proof of failure.
