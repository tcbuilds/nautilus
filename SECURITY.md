# Security Policy

## Supported versions

This repository is documentation and templates. Security fixes apply to the current `main` branch.

## Reporting a vulnerability

Do not open a public issue for secrets, credential exposure, or a sanitization bypass. Use GitHub private vulnerability reporting if enabled for this repository. If it is not enabled, contact the maintainers through the repository owner profile.

Include:

- A short description of the issue.
- The affected file or template.
- Steps to reproduce or verify the leak.
- Any suggested remediation.

## Sensitive data rules

Do not commit credentials, API keys, private hostnames, customer names, personal paths, screenshots with secrets, or private project details. Sanitized examples should use placeholders such as `<api-key>`, `<project-name>`, `<service-url>`, and `<home>`.

Before publishing a change, search for common leakage patterns:

```bash
rtk rg -n "secret|token|password|api_key|private|/home/|~/.claude" .
```
