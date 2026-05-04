# Token Economy

Cross-cutting tooling that cuts token spend across every workflow phase. Tokens are the unit cost of working with Claude Code — fewer tokens per task means more tasks per dollar, faster turn times, and longer effective context windows before compaction kicks in. Two open-source projects earn their place in the playbook because they compound across long sessions without trading away technical accuracy.

## The two levers

| Tool | Side it cuts | How it works | Typical savings |
|---|---|---|---|
| **[caveman](https://github.com/JuliusBrussee/caveman)** | Output (assistant → user) | Compression style applied to assistant prose. Drops articles, filler, hedging, pleasantries. Keeps code, errors, identifiers exact. | ~65% mean (22–87% range) on prose responses |
| **[rtk](https://github.com/rtk-ai/rtk)** | Tool input (shell → context) | Rust CLI proxy that intercepts common dev commands (`git`, `ls`, `grep`, `cargo test`, `pytest`, `gh`, etc.) and returns filtered, compact output instead of raw verbose dumps. | ~60–90% per command, ~80% across a typical 30-min session |

They stack. caveman shrinks what the model writes back to you; rtk shrinks what the model has to read from tool results. Together they extend the practical lifespan of a session by 2–3× before context pressure forces compaction. Both projects ship installers that target Claude Code, Codex, Gemini CLI, Cursor, Windsurf, Cline, and 25+ other agents — adoption is not Claude-Code-specific.

## caveman

Built and maintained by [Julius Brussee](https://github.com/JuliusBrussee) — source at [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). MIT licensed.

A Claude Code skill / Codex plugin that makes the agent talk like a caveman. Activated via `/caveman` (or `$caveman` in Codex) with three intensity levels and a Wenyan (classical Chinese literary) variant for extreme compression:

- **lite** — `/caveman lite` — drops only obvious filler. Reads close to normal prose.
- **full** (default) — `/caveman full` — fragments OK, articles dropped, short synonyms preferred. Still grammatical.
- **ultra** — `/caveman ultra` — abbreviates prose words (DB, auth, config, fn, impl), strips conjunctions, uses arrows for causality (`X → Y`). One word when one word is enough.
- **wenyan / wenyan-lite / wenyan-ultra** — classical Chinese literary compression. The most token-efficient written language humans ever invented, deployed for the same technical content.

Code blocks, function names, API names, and error strings are never abbreviated at any level. Technical substance is preserved.

### Real benchmarks, not vibes

The project ships an `evals/` directory with a three-arm harness that compares verbose Claude, plain-terse Claude, and caveman Claude — measuring real Claude API token counts rather than self-reported estimates. Headline numbers from the published benchmark table:

| Task | Normal | Caveman | Saved |
|---|---:|---:|---:|
| Explain React re-render bug | 1180 | 159 | **87%** |
| Set up PostgreSQL connection pool | 2347 | 380 | **84%** |
| Implement React error boundary | 3454 | 456 | **87%** |
| Refactor callback to async/await | 387 | 301 | 22% |
| **Mean across 10 tasks** | **1214** | **294** | **65%** |

The 22% floor matters: when the original answer is already concise (small refactors, short architecture takes), caveman has less to cut. The compression isn't lossy padding-removal — it's adapted to the prose volume actually present.

### The research backing

A March 2026 paper, *["Brevity Constraints Reverse Performance Hierarchies in Language Models"](https://arxiv.org/abs/2604.00025)*, found that constraining large models to brief responses **improved accuracy by 26 percentage points** on certain benchmarks and completely reversed performance hierarchies — a smaller model under a brevity constraint outperformed a larger one without. The implication is that verbose output isn't a free signal of capability; it can actively degrade correctness on reasoning tasks. Caveman operationalizes that finding as a default mode rather than an exception.

> [!IMPORTANT]
> Caveman compresses **output tokens only**. Internal reasoning / thinking tokens are untouched. Caveman does not make the model think less; it makes the model talk less. The largest practical wins are readability, response speed, and reduced context bloat — cost savings are a bonus, not the headline.

### The wider ecosystem

Caveman is the output-compression piece of a three-tool philosophy:

| Repo | Role | Mechanism |
|---|---|---|
| [**caveman**](https://github.com/JuliusBrussee/caveman) | Talk less | Output prose compression |
| [**cavemem**](https://github.com/JuliusBrussee/cavemem) | Remember more | Compressed SQLite + MCP for cross-agent persistent memory |
| [**cavekit**](https://github.com/JuliusBrussee/cavekit) | Build better | Spec-driven autonomous build loop |

Each stands alone. Together they form an end-to-end discipline: cavekit drives the build, caveman compresses what the agent says, cavemem compresses what the agent remembers.

### Companion skills bundled with caveman

| Skill | What |
|---|---|
| `/caveman-commit` | Terse commit messages. Conventional Commits, ≤50-char subject, why-over-what body. |
| `/caveman-review` | One-line PR comments: `L42: 🔴 bug: user null. Add guard.` |
| `/caveman-stats` | Real session token usage + estimated savings + USD. Reads Claude Code session JSONL directly — no model-side guessing. |
| `/caveman:compress <file>` | Rewrites a memory file (e.g. `CLAUDE.md`) into caveman-speak, saves backup as `<file>.original.md`. **Cuts ~46% of *input* tokens every session start.** Code, URLs, and paths preserved byte-for-byte. |
| `caveman-shrink` (MCP middleware) | Stdio proxy that wraps any MCP server, intercepts `tools/list` / `prompts/list` / `resources/list` responses, and compresses the `description` fields. Code/URLs/paths byte-identical. |
| `cavecrew-investigator` / `builder` / `reviewer` | Caveman subagents whose tool-output gets injected back into main context — emit ~60% fewer tokens than vanilla `Explore` / reviewer agents. |

The compress skill is the highest-leverage one to adopt early: a single one-time compression of a verbose `CLAUDE.md` saves tokens on **every session start** for the lifetime of the project.

### When caveman auto-relaxes

Security warnings, irreversible action confirmations, multi-step sequences where omitted conjunctions could cause misreads, and any moment the user asks for clarification. The skill resumes after the clarity-critical part is done.

### When to skip caveman entirely

Commits, PR descriptions, documentation, customer-facing copy, or any artifact that will be read outside the session. Caveman is for the live conversation channel, not for shipped prose. The bundled `/caveman-commit` and `/caveman-review` skills are the exception — they are designed to produce shipped artifacts that are *terse but still proper prose*, not caveman-speak.

## rtk

Built and maintained by the [rtk-ai](https://github.com/rtk-ai) team — source at [github.com/rtk-ai/rtk](https://github.com/rtk-ai/rtk). Apache-2.0 licensed.

A single Rust binary (zero runtime dependencies, <10ms overhead) that sits between Claude Code and the shell. Every dev command Claude Code would normally run gets transparently rewritten through rtk, which strips noise and returns the structured signal the model actually needs. 100+ commands supported out of the box.

### The four strategies

rtk applies different tactics per command type:

1. **Smart filtering** — removes paginator headers, ANSI escapes, ASCII art, boilerplate progress lines, "Using gem ..." spam.
2. **Grouping** — aggregates similar items: lint errors collapsed by rule, files collapsed by directory, test failures grouped by file.
3. **Truncation** — keeps relevant context, cuts redundancy. Long output is summarized with a recovery handle (`tee` to disk) so the full version is still reachable when needed.
4. **Deduplication** — collapses repeated log lines into `(×N)` counts.

### What gets compressed

A representative slice of a 30-minute Claude Code session, from rtk's published numbers:

| Operation | Frequency | Standard | rtk | Savings |
|---|---|---:|---:|---:|
| `ls` / `tree` | 10× | 2,000 | 400 | -80% |
| `cat` / `read` | 20× | 40,000 | 12,000 | -70% |
| `grep` / `rg` | 8× | 16,000 | 3,200 | -80% |
| `git status` | 10× | 3,000 | 600 | -80% |
| `git diff` | 5× | 10,000 | 2,500 | -75% |
| `git add/commit/push` | 8× | 1,600 | 120 | **-92%** |
| `cargo test` / `npm test` | 5× | 25,000 | 2,500 | **-90%** |
| `pytest` | 4× | 8,000 | 800 | **-90%** |
| **Session total** | | **~118,000** | **~23,900** | **-80%** |

The ~80% session-level reduction is the load-bearing number. Individual `git push` / commit operations clock -92% because rtk collapses 15-line "Enumerating objects... Counting objects... Delta compression..." dumps into a single `ok main`. Test runners drop -90% by reporting only failures with structured locations.

### Coverage

| Domain | Examples |
|---|---|
| Files | `rtk ls`, `rtk read`, `rtk find`, `rtk grep`, `rtk diff`, `rtk smart` (heuristic code summary) |
| Git / GitHub | `rtk git status/log/diff/add/commit/push/pull`, `rtk gh pr list/view`, `rtk gh issue list`, `rtk gh run list` |
| Tests | Jest, Vitest, Playwright, pytest, go test, cargo test, RSpec, minitest, generic `rtk test <cmd>` and `rtk err <cmd>` |
| Build / Lint | ESLint, Biome, tsc, Next.js, Prettier, cargo build/clippy, ruff, golangci-lint, RuboCop |
| Packages | pnpm, pip (auto-detects uv), bundle, prisma |
| Cloud | AWS (sts, ec2, lambda, logs, cloudformation, dynamodb, iam, s3), kubectl, docker, docker compose |
| Data / misc | `rtk json` (structure without values), `rtk env -f`, `rtk log`, `rtk curl`, `rtk wget`, `rtk summary`, `rtk proxy` (raw passthrough + tracking) |

### Hook integration

The hook integration makes rtk invisible — `git status` becomes `rtk git status` automatically; the model sees the compact output, not the raw verbose dump. Install per agent:

```bash
rtk init -g                  # Claude Code / Copilot (default)
rtk init -g --gemini         # Gemini CLI
rtk init -g --codex          # Codex
rtk init --agent cursor      # Cursor (also: windsurf, cline, kilocode, antigravity)
```

> [!IMPORTANT]
> The hook **only runs on Bash tool calls**. Claude Code's built-in `Read`, `Grep`, and `Glob` tools bypass the Bash hook and are not auto-rewritten. To benefit from rtk in those workflows, either use shell commands (`cat`, `head`, `rg`, `find`) or call `rtk read` / `rtk grep` / `rtk find` explicitly. This is the single most common reason a project shows lower-than-expected `rtk gain` numbers.

### Meta commands

These stay explicit (the hook does not rewrite them):

- `rtk gain` — cumulative token savings for the session
- `rtk gain --graph` — ASCII graph of last 30 days
- `rtk gain --history` — per-command savings breakdown
- `rtk gain --daily` — day-by-day breakdown
- `rtk gain --all --format json` — JSON export for dashboards
- `rtk discover` — scan past Claude Code logs for missed compression opportunities
- `rtk session` — show RTK adoption across recent sessions
- `rtk proxy <cmd>` — escape hatch to run a raw command without filtering, with savings still tracked
- `-u` / `--ultra-compact` global flag — ASCII icons + inline format for extra savings on any rtk subcommand

## How to adopt these in a project

1. **Install rtk first** before starting any non-trivial Claude Code session. `brew install rtk` (recommended) or `cargo install --git https://github.com/rtk-ai/rtk`. Verify with `rtk --version` (should show `rtk 0.28.x`) and `rtk gain`. If `rtk gain` fails with "command not found," check for the name collision with the unrelated `rtk` (Rust Type Kit) crate on crates.io and reinstall via the git URL.
2. **Wire the hook** with `rtk init -g` for the agent in use. Then restart the agent and verify with a `git status` — output should be one or two compact lines, not a verbose dump.
3. **Install caveman** via the one-liner: `curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash`. The installer detects every agent on the machine and wires each one's native install path. Default install also registers the `caveman-shrink` MCP proxy.
4. **Run `/caveman:compress` on every project's `CLAUDE.md` once.** This is the highest-leverage one-time action — it compresses the always-loaded project memory and pays back on every single session start for the project's lifetime. Backup is saved as `CLAUDE.md.original.md` automatically.
5. **Reach for caveman mode when prose volume gets noisy.** Long debugging sessions, multi-turn investigations, status updates — these are where caveman pays. Toggle with `/caveman lite|full|ultra`. Disable with `stop caveman` or `normal mode`.
6. **Check `rtk gain` and `/caveman-stats` weekly.** If `rtk gain` shows low savings, the hook isn't running on enough commands — usually because Claude Code's built-in `Read` / `Grep` are being used instead of shell `cat` / `rg` (see the scope warning above), or because a custom command isn't yet covered by rtk. If `/caveman-stats` shows low savings, the skill isn't activating consistently — check the hook install or invoke `/caveman` explicitly.
7. **Don't compress what shouldn't be compressed.** Commits, PRs, postmortems, ADRs, and shipped docs always render in normal prose. Both tools have boundary rules baked in; trust them and do not override.

## Why this earns a place in the playbook

Token cost is the dominant ongoing cost of an AI-assisted workflow. A project that ships through dozens of Claude Code sessions will spend orders of magnitude more on inference than on every other line item combined. Tools that cut that cost without sacrificing correctness — and in caveman's case, with a published benchmark and a peer-reviewable arXiv paper backing the approach — are not optional polish. They are foundational infrastructure, on the same tier as version control or CI. Treating them as such early prevents the slow drift where a project's burn rate balloons because nobody installed the obvious lever.

Both projects are open-source, actively maintained, and ship installers that target every major coding agent. Adopting them costs an afternoon. Not adopting them costs every session afterward.
