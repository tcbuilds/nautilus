# examples/

This directory holds real past trios from completed projects and examples of AI harness configuration:

- `mvp.md` — the refined spec.
- `CLAUDE.md` — the project-level orchestrator instructions.
- `implementation_plan.md` — the phased roadmap.
- `harnesses/` — global configuration examples for specific AI coding harnesses.

Project examples live in their own subdirectories named after the project. Harness examples live under `harnesses/<harness>/` and are intended to be copied into the corresponding global configuration directory.

## Sanitization

Every example must be sanitized before being added:

- No credentials, API keys, tokens, or secrets of any kind.
- No private business data, customer information, or partner contracts.
- No internal-only URLs, hostnames, or infrastructure details.
- Names of services or integrations may stay if they are public knowledge; specifics of the deployment must not.

If you can't sanitize an example without removing what made it instructive, leave it out.

## Why we keep these

Templates show the shape. Examples show what real, completed instances look like. Future sessions can copy from a known-good example and adapt rather than starting from a blank template every time.

The first chamber is empty. As projects ship, they get added here.
