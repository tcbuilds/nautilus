---
name: data-classification
description: Classify project data flows and repositories for sensitive data handling. Use for CUI, PII, PHI, secrets, export-controlled data, customer confidential data, logs, telemetry, and retention questions. Produces data_classification.md.
---

# Data Classification

Identify what data a project handles, where it flows, how it is stored, and what handling rules should apply.

## When to invoke

Use before architecture work, public release, customer onboarding, compliance review, LLM/MCP integration, data migration, analytics setup, or production logging changes.

## Process

1. Inventory data sources: user input, uploads, logs, external APIs, databases, queues, files, telemetry, model prompts, MCP tools.
2. Classify data by sensitivity:
   - Public
   - Internal
   - Confidential
   - Regulated or controlled
   - Secret/credential material
3. Trace lifecycle: collection, processing, storage, transmission, logging, backup, retention, deletion.
4. Identify unsafe handling: over-logging, broad access, unclear retention, third-party egress, unencrypted storage, unredacted exports.
5. Write `data_classification.md`.

## Report outline

```markdown
# Data Classification

## Summary
## Data Inventory
## Data Flows
## Classification Table
## Handling Rules
## Logging and Telemetry Rules
## Third-Party Sharing
## Retention and Deletion
## Open Questions
```

## Classification table

| Data | Source | Classification | Stored where | Shared with | Retention | Notes |
|---|---|---|---|---|---|---|
| Example | API form | Confidential | Database | None | 90 days | Redact from logs |

## Guardrails

- Do not paste real sensitive values into the report.
- If classification is uncertain, mark `Needs data owner review`.
- Do not downgrade data because it is inconvenient to protect.
- Treat prompts, tool outputs, embeddings, logs, and traces as data stores.
