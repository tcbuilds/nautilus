---
name: nautilus-sync
description: Sync a personal skill or agent from ~/.claude/ into a public-facing nautilus-shaped playbook repo as a sanitized loadable artifact. Use when asked to "sync skill X to nautilus", "promote agent Y to playbook", "nautilus-sync skill Z", "publish skill to my playbook repo".
allowed-tools: Read, Write, Edit, Bash(python3:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(cp:*), Bash(test:*), Bash(diff:*), Bash(wc:*), Bash(rg:*), Bash(grep:*), Grep, Glob
---

# Nautilus Sync

Bridge a personal skill (`~/.claude/skills/<name>/`) or agent (`~/.claude/agents/<name>.md`) into a nautilus-shaped public playbook repo as a sanitized, loadable artifact. The output preserves the directory layout that `install-tools.sh` expects so the artifact installs cleanly into other people's `~/.claude/`.

## Usage

```
/nautilus-sync skill <name>            # uses $NAUTILUS_REPO or default
/nautilus-sync agent <name>
/nautilus-sync skill <name> --repo /path/to/nautilus
```

Natural-language equivalents trigger the same flow ("sync the github-master agent to my nautilus repo", "promote backlink-builder to the playbook").

## Target repo resolution

The skill needs to know where the public nautilus-shaped repo lives on disk. Resolution order:

1. `--repo PATH` flag if passed.
2. `$NAUTILUS_REPO` environment variable.
3. `$HOME/nautilus` if it exists and contains both `skills/` and `agents/` directories.
4. Otherwise: error out with a clear message asking the user to clone the repo (`gh repo clone <owner>/<nautilus-fork> ~/nautilus`) or pass `--repo`.

The resolved path is referred to as `$REPO` below.

## Step-by-step

### 1. Parse args

Extract `type` (`skill` or `agent`) and `name` from the invocation. If the user gave only a name, infer type by checking which path exists:
- `~/.claude/skills/<name>/SKILL.md` → skill
- `~/.claude/agents/<name>.md` → agent

If neither exists, report the missing paths and stop.

### 2. Resolve target paths

| Type | Source | Target |
|---|---|---|
| skill | `~/.claude/skills/<name>/` (full directory) | `$REPO/skills/<name>/` (full directory) |
| agent | `~/.claude/agents/<name>.md` | `$REPO/agents/<name>.md` |

Skills are directories — copy every file inside (SKILL.md plus any `scripts/`, `references/`, `templates/`, helper assets). Agents are single files.

### 3. Run the sanitizer

The sanitizer at `scripts/sanitize.py` is a stdin → stdout filter. For each source file (every file inside a skill directory, or the single agent file), pipe through the sanitizer and capture stats from stderr.

```bash
python3 ~/.claude/skills/nautilus-sync/scripts/sanitize.py \
  < <source-file> > /tmp/nautilus-sync.sanitized 2> /tmp/nautilus-sync.stats
```

Stats line entries look like `path: 4`, `identity: 2`, `credential material: 1`, etc.

For binary files inside a skill (rare — usually images), copy them as-is without sanitization.

### 4. Verify nothing slipped through

After sanitizing every file, run a final grep against the staged outputs to catch anything the sanitizer's regex set missed:

```bash
rg -n '/home/|/Users/|@gmail\.com|@yahoo\.com|@outlook\.com' /tmp/nautilus-sync-staging/
```

If anything matches, stop and surface it to the user. Don't silently overwrite — let them decide whether to extend the sanitizer or hand-edit before publishing.

### 5. Write to the target repo

For skills:
- `mkdir -p $REPO/skills/<name>/` (and any subdirectories the source uses)
- Copy each sanitized file into place
- If the target directory exists, replace the contents (sync semantics — match `install-tools.sh` behavior)

For agents:
- Write the sanitized file to `$REPO/agents/<name>.md`

Before overwriting, if a target file already exists:
- Compute line count of existing target vs new content (`wc -l`).
- If new content differs by more than 50% of existing line count, print a warning and show the user a unified diff (`diff -u` between old and new) before overwriting.

### 6. Update the index

| Type | Index file |
|---|---|
| skill | `$REPO/skills-index.md` |
| agent | `$REPO/agents-index.md` |

Read the index. If a row matching `\`/<name>\`` (skill) or `\`<name>\`` (agent) already exists, leave the index untouched.

Otherwise append a new row to the markdown table.

**Skill row format:**
```
| `/<name>` | <one-line purpose> | <workflow phase or "general"> |
```

**Agent row format:**
```
| `<name>` | <specialization> | <when to delegate> |
```

Use `Edit` to insert the row in alphabetical order within the existing table. Preserve the table header and any explanatory paragraphs around it.

### 7. Print summary

Output to the user:
- Source path → target path (per file for skills with multiple files)
- Sanitization stats from stderr (e.g. "stripped 4 path refs, 2 identity strings, 1 API key")
- Whether the index was updated or already had the entry
- Whether a >50% size change warning was triggered
- Final grep result confirming no leakage in the staged output

## Constraints

- **Single source of truth is `~/.claude/`.** Never write back to the source. Sync flows downstream only.
- **Idempotent.** Rerunning on an unchanged source produces no diff. The sanitizer is deterministic.
- **Loadable artifacts only.** The output must match the directory shape `install-tools.sh` expects: skills as directories under `skills/<name>/` containing `SKILL.md`, agents as single files under `agents/<name>.md`. Don't reframe into separate prose docs — keep frontmatter intact so Claude Code can load the artifact directly.
- **No fabrication.** If sanitization would gut the skill (e.g. it's irreducibly tied to a private API), report that to the user instead of shipping a broken artifact.
- **Don't auto-commit.** This skill writes files but does not run `git commit` or `git push`. The user reviews and commits manually.

## Cleanup

Remove `/tmp/nautilus-sync.sanitized`, `/tmp/nautilus-sync.stats`, and `/tmp/nautilus-sync-staging/` after the run.

## Failure modes

- Source file missing → report both checked paths, stop.
- Both `~/.claude/skills/<name>/` and `~/.claude/agents/<name>.md` exist (rare) → ask user which type to sync.
- Target repo not resolved (no flag, no env var, no `~/nautilus`) → stop with a message explaining the three resolution options.
- Index file missing → create the index with a header row, then append.
- Sanitizer crashes → show stderr, stop. Do not write a partially sanitized target.
- Final grep finds leakage → stop. Surface the matches and let the user decide.
