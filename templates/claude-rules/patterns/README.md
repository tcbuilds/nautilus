# Language Rules

Per-language pattern files that extend the always-loaded baseline in
`../standards.md`.

## How to use

Each project copies the files for its languages into `.claude/rules/patterns/`.
Claude loads a pattern only when its `paths:` frontmatter matches a file being
read or edited.

Each file uses YAML `paths:` frontmatter so it only enters context when Claude reads matching files — keeps token usage down in polyglot repos.

These files pair with `templates/claude-rules/standards.md`. The baseline covers
universal rules; each pattern file covers language-specific idioms.

## Available files

- **`rust.md`** — Rust 1.80+ / edition 2021. Error handling with `anyhow`/`thiserror`, async Tokio patterns, ownership idioms, lock-free primitives.
- **`python.md`** — Python 3.10+. Type hints, dataclasses, async patterns, exception discipline, structural pattern matching.
- **`typescript.md`** — TypeScript 4.5+. Strict tsconfig, `unknown` over `any`, discriminated unions, async patterns, error cause chains.

## After copying

Trim sections that do not apply to the project, and extend with rules learned during the build. The copy in `.claude/rules/` is the project's living document — these files in `nautilus` are the starting points.
