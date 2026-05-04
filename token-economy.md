# Token Economy

Cross-cutting tooling that cuts token spend across every workflow phase. Tokens are the unit cost of working with Claude Code — fewer tokens per task means more tasks per dollar, faster turn times, and longer effective context windows before compaction kicks in. Two tools earn their place in the playbook because they compound across long sessions without trading away technical accuracy.

## The two levers

| Tool | Side it cuts | How it works | Typical savings |
|---|---|---|---|
| **[caveman](https://github.com/JuliusBrussee/caveman)** | Output (assistant → user) | Compression style applied to assistant prose. Drops articles, filler, hedging, pleasantries. Keeps code, errors, identifiers exact. | ~50–75% on prose responses |
| **[rtk](https://github.com/rtk-ai/rtk)** | Tool input (shell → context) | Rust CLI proxy that intercepts common dev commands (`git`, `ls`, `grep`, etc.) and returns filtered, compact output instead of raw verbose dumps. | ~60–90% on dev-command tool results |

They stack. caveman shrinks what the model writes back to you; rtk shrinks what the model has to read from tool results. Together they extend the practical lifespan of a session by 2–3× before context pressure forces compaction.

## caveman mode

Built and maintained by [Julius Brussee](https://github.com/JuliusBrussee) — source at [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).

A compression skill activated via `/caveman` with three intensity levels:

- **lite** — drops only obvious filler. Reads close to normal prose.
- **full** (default) — fragments OK, articles dropped, short synonyms preferred. Still grammatical.
- **ultra** — abbreviates prose words (DB, auth, config, fn, impl), strips conjunctions, uses arrows for causality (`X → Y`). One word when one word is enough.

Code blocks, function names, API names, and error strings are never abbreviated at any level. Technical substance is preserved.

**When caveman auto-relaxes**: security warnings, irreversible action confirmations, multi-step sequences where omitted conjunctions could cause misreads, and any moment the user asks for clarification. The skill resumes after the clarity-critical part is done.

**When to skip caveman entirely**: writing commits, PR descriptions, documentation, customer-facing copy, or any artifact that will be read outside the session. Caveman is for the live conversation channel, not for shipped prose.

## rtk

Built and maintained by the [rtk-ai](https://github.com/rtk-ai) team — source at [github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk).

A Rust-based CLI proxy that sits between Claude Code and the shell. Every dev command Claude Code would normally run gets transparently rewritten through rtk, which strips noise (paginator headers, ANSI escapes, ASCII art, boilerplate progress lines) and returns the structured signal the model actually needs.

The hook integration makes it invisible — `git status` becomes `rtk git status` automatically; the model sees the compact output, not the raw verbose dump.

Meta commands stay explicit:

- `rtk gain` — show cumulative token savings for the session
- `rtk gain --history` — per-command savings breakdown
- `rtk discover` — scan past Claude Code logs for missed compression opportunities
- `rtk proxy <cmd>` — escape hatch to run a raw command without filtering, for debugging

## How to adopt these in a project

1. **Install rtk locally** before starting any non-trivial Claude Code session. Verify with `rtk --version` and `rtk gain`. If `rtk gain` fails with "command not found," check for the name collision with `reachingforthejack/rtk` (Rust Type Kit) and reinstall the correct binary.
2. **Reach for caveman when prose volume gets noisy.** Long debugging sessions, multi-turn investigations, status updates — these are where caveman pays. Toggle with `/caveman lite|full|ultra`. Disable with `stop caveman` or `normal mode`.
3. **Watch `rtk gain` periodically.** If a project shows low savings, that's a signal you're not running enough commands through rtk — usually because the hook isn't installed or a custom command isn't covered yet.
4. **Don't compress what shouldn't be compressed.** Commits, PRs, postmortems, and shipped docs always render in normal prose. Both tools have boundary rules baked in; trust them.

## Why this earns a place in the playbook

Token cost is the dominant ongoing cost of an AI-assisted workflow. A project that ships through dozens of Claude Code sessions will spend orders of magnitude more on inference than on every other line item combined. Tools that cut that cost without sacrificing correctness are not optional polish — they are foundational infrastructure, on the same tier as version control or CI. Treating them as such early prevents the slow drift where a project's burn rate balloons because nobody installed the obvious lever.
