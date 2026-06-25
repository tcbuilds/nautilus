---
name: secure-code-review
description: Review code changes for security defects. Use for auth, authorization, injection, secrets, logging, dependencies, file handling, network calls, deserialization, LLM/MCP tools, and data exposure risks. Produces review findings with severity and fixes.
---

# Secure Code Review

Perform a security-focused code review. Prioritize exploitable behavior, data exposure, missing controls, and unsafe defaults.

## When to invoke

Use on PRs, large diffs, auth changes, API endpoints, file parsers, deployment scripts, CI workflows, LLM/MCP integrations, and data handling code.

## Review areas

- Authentication and session handling
- Authorization and object-level access control
- Input validation and output encoding
- SQL/NoSQL/command/template injection
- Path traversal and unsafe file handling
- SSRF and unrestricted network egress
- Secrets in code, logs, errors, tests, or build artifacts
- Dependency, container, and CI supply-chain risk
- Unsafe deserialization or dynamic code execution
- Missing timeouts, rate limits, or resource bounds
- PII, controlled data, or regulated data exposure
- LLM prompt injection and unsafe MCP/tool invocation

## Finding format

```markdown
### [HIGH] Missing object-level authorization on document read

**Location:** `path/to/file.ext:123`
**Risk:** User can access another user's document by changing an ID.
**Evidence:** Handler loads by ID without checking owner/team membership.
**Fix:** Require ownership or scoped permission check before returning data.
```

## Guardrails

- Lead with findings, ordered by severity.
- Include file and line references when available.
- Distinguish confirmed bugs from questions.
- Do not recommend noisy best-practice work unless tied to a concrete risk.
- Do not paste secrets into review output; redact them and flag rotation if exposed.
