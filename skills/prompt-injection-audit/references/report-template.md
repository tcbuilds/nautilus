# LLM and Agent Injection Audit

**Target:** [path]
**Date:** [date]
**Standards check:** [fetched 2026 PDF / used snapshot; live list page agreed or lagged]
**Stack:** [providers, frameworks, model IDs, pinned or not]
**Swarm model:** openai-codex/gpt-6-luna:max

| Lane | Agent | Recorded model | Accepted |
| --- | --- | --- | --- |
| Ingress and prompt construction | red-team-analyst | [must be openai-codex/gpt-6-luna:max] | yes/no |
| Tools, MCP, and agency | red-team-analyst | [must be openai-codex/gpt-6-luna:max] | yes/no |
| Retrieval, memory, and hidden context | red-team-analyst | [must be openai-codex/gpt-6-luna:max] | yes/no |
| Output, disclosure, and consumption | red-team-analyst | [must be openai-codex/gpt-6-luna:max] | yes/no |
| Supply chain and architecture | red-team-analyst | [must be openai-codex/gpt-6-luna:max] | yes/no |
**Call sites read:** [count read] / [count found]
**Verdict:** Pass | Needs hardening | Fail

## Rule of Two

| Component | Untrusted input | Sensitive data | State change or external send | Gate seen | Result |
| --- | --- | --- | --- | --- | --- |
| [name and file:line] | yes/no | yes/no | yes/no | [control or none] | approval required / residual risk / acceptable |

## Control scorecard

| Control | Status | Evidence |
| --- | --- | --- |
| LLM01-1 Role constraint | yes/no/n/a | [file:line or why n/a] |
| LLM01-2 Deterministic output schema | yes/no/n/a | |
| LLM01-3 Modality filtering | yes/no/n/a | |
| LLM01-4 Credentials and policy outside the model | yes/no/n/a | |
| LLM01-5 Invisible-character stripping | yes/no/n/a | |
| LLM01-6 Labeled external-content channel | yes/no/n/a | |
| LLM01-7 Exact-action human approval | yes/no/n/a | |
| LLM01-8 Rule of Two | yes/no/n/a | |
| LLM01-9 Memory-write gate | yes/no/n/a | |
| LLM01-10 Pinned and reviewed tools/MCP | yes/no/n/a | |
| LLM01-11 Adaptive-test evidence | yes/no/n/a | |
| LLM03 Tool least privilege | yes/no/n/a | |
| LLM08 No secrets in hidden context | yes/no/n/a | |
| LLM10 Sink-specific output handling | yes/no/n/a | |
| LLM02/LLM09 Tenant isolation | yes/no/n/a | |
| LLM06 Hard resource limits | yes/no/n/a | |

## Coverage

| ID | Status | Notes |
| --- | --- | --- |
| LLM01 Prompt Injection | covered / gap / n/a | |
| LLM02 Sensitive Information Disclosure | | |
| LLM03 Excessive Agency | | |
| LLM04 Supply Chain | | |
| LLM05 Data and Model Poisoning | | |
| LLM06 Unbounded Consumption | | |
| LLM07 Misinformation | | |
| LLM08 Hidden Context Exposure | | |
| LLM09 Vector and Embedding Weaknesses | | |
| LLM10 Improper Output Handling | | |
| ASI01-ASI10 | covered / n/a | [n/a only when the model cannot act] |

## Counts

| Severity | Confirmed | Likely | Gap |
| --- | --- | --- | --- |
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |

## Findings

### [severity] [title]

- **Status:** confirmed | likely | gap
- **Location:** `file:line`
- **IDs:** [LLM0x:2026; 2025 ID if different; ASI0x if the model can act]
- **Effect:** [what untrusted input can read, change, or send]
- **Evidence:** [short code observation; no secrets]
- **Missing control:** [name of the control that should block the effect]
- **Fix:** [smallest change in trusted code]

## Call-site inventory

| Location | Inputs | Tools | Output sink | Independent control |
| --- | --- | --- | --- | --- |
| `file:line` | [sources and roles] | [names or none] | [sink] | [control or none] |

## Not read

- [file or pattern, and why]

## Residual risk

- [limits, unread paths, and controls that reduce success but do not bound damage]
