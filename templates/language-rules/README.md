# Language Rules

Per-language pattern files that extend the cross-language baseline in `../codingStandards.md`.

## How to use

Each project picks **one** file matching its primary language and copies it into `.claude/rules/` at the project root. Claude Code auto-loads anything in `.claude/rules/` as part of project context, so the patterns become persistent guidance without needing to be invoked.

These files pair with `templates/codingStandards.md` — the cross-language baseline that is copied to the project root. The baseline covers universal rules (no swallowed errors, no unbounded queues, secrets hygiene). The language file covers idioms specific to the chosen language.

## Available files

- **`rust-patterns.md`** — Rust 1.80+ / edition 2021. Error handling with `anyhow`/`thiserror`, async Tokio patterns, ownership idioms, lock-free primitives.
- **`python-patterns.md`** — Python 3.10+. Type hints, dataclasses, async patterns, exception discipline, structural pattern matching.
- **`typescript-patterns.md`** — TypeScript 4.5+. Strict tsconfig, `unknown` over `any`, discriminated unions, async patterns, error cause chains.

## After copying

Trim sections that do not apply to the project, and extend with rules learned during the build. The copy in `.claude/rules/` is the project's living document — these files in `nautilus` are the starting points.
