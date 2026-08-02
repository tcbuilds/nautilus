---
name: codex-review
description: Run a second-pass Codex review over changed files, produce severity-ordered findings, and escalate repeated fix-loop invariants to a Sol-max repair architect. Use after implementation, before marking tasks complete, before merge requests/pull requests, when a skeptical review is needed, or when fixes become whack-a-mole.
---

# Codex Review

Independent gate for correctness, security/data handling, performance/resources, and tests. Review only task-relevant changed files; preserve unrelated changes.

## Profiles and launch

Inspect before installing under `${CODEX_HOME:-$HOME/.codex}/`:
- `assets/sol_high_reviewer.config.toml` -> `sol_high_reviewer.config.toml`
- `assets/sol_max_fix_architect.config.toml` -> `sol_max_fix_architect.config.toml`

Preflight the installed file, not `codex ... --help` (help does not load the profile): require the exact `${CODEX_HOME:-$HOME/.codex}/<name>.config.toml`, parse it with a local TOML parser, and assert expected model, effort, network, and delegation pins. Launch with `--strict-config` for Codex's recognized-key check. Reviewer pins `gpt-5.6-sol` high; architect pins Sol max. No priority flag, Terra, or model fallback. Retry capacity errors with bounded backoff, else block gate.

### Variables

| Variable | Meaning |
|---|---|
| `<skill-dir>` | Absolute path of this skill directory, the parent of `assets/`. |
| `<files>` | Scoped file list from the review contract step 1. Never the whole repo. |
| `$OUT` | Writable path for the complete-review JSON, e.g. `"$(mktemp -d)/codex-review.json"`. Reused for verification output. |
| `$CLARIFY_OUT` | Writable path for the one clarification JSON. |
| `$ARCH_OUT` | Writable path for the repair-architect JSON. |
| `<packet-path>` | Path of the compact repair evidence packet written before the architect launch. |
| `$SESSION_ID` | Session id of the round-1 reviewer run. `codex exec` writes session files under `${CODEX_HOME:-$HOME/.codex}/sessions/`, but read the id only from this run's own authoritative output metadata. If it is absent or cannot be bound to this run, do not resume and do not guess from directory listings: use the fresh scoped-verification fallback instead. |

Create output paths under a temp dir the orchestrator owns, and delete them at closure unless the user asks to keep them.

```bash
rtk proxy timeout 1800 codex exec -p sol_high_reviewer --strict-config \
  --add-dir "$HOME/.local/share/rtk" --skip-git-repo-check \
  --output-schema "<skill-dir>/assets/review-result.schema.json" -o "$OUT" \
  "Review these files. Review only: do not edit files. Compare target baseline to HEAD before classifying each finding. Use RTK for shell commands. Files: <files>. Cover correctness, security and data handling, performance and resource use, and tests and verification. Order findings by severity. Label each finding EMPIRICALLY_VERIFIED, PROBED, or HYPOTHETICAL and classify scope_status as REGRESSION, NEWLY_REACHABLE, PRE_EXISTING, or HYPOTHETICAL. For every finding identify why the changed diff owns it, the violated invariant, failing execution path, repair direction, and named proof test. Suggest the repair direction but do not write an executor brief. Return JSON matching the supplied schema. Keep prose terse; preserve code, commands, identifiers, probe output, and exact error strings verbatim." \
  < /dev/null
```

Run in background. Network is enabled for all hosts. Keep `rtk proxy`, `timeout 1800`, RTK writable dir, strict profile/schema, and `< /dev/null`. Without RTK, remove wrapper and report fallback. Missing/empty `$OUT`, nonzero exit, or timeout means gate did not run; never infer no findings. Inspect session JSONL (`turn_aborted`, restart evidence) before retry/resume/re-scope.

## Review contract

1. Derive scoped tracked/untracked files from user input and Git state.
2. Resolve the coding standards file by cascade: repo `.claude/rules/coding-standards.md`, else `~/.claude/rules/coding-standards.md`, else repo `templates/codingStandards.md`. Read the first that exists plus the matching `*-patterns.md`, and cite explicit violations by standard name/ID, minimum Medium. If none exists, skip the standards-citation requirement and record in the output that no standards file was found.
3. With `.codegraph/`, use `codegraph explore` for structural questions and inspect callers of every changed public symbol. Report affected untouched callers/call paths and list checked symbols. Without index, record read-only blast-radius method.
4. Require findings in severity order. Each has evidence class, stable fingerprint, scope status, violated invariant, failing path, repair direction, named proof test, and evidence. Reviewer direction is not executor brief.
5. Compare every candidate finding against the target baseline before scoring it. Use `REGRESSION` when the diff introduces a defect, `NEWLY_REACHABLE` when the diff materially expands reachability or impact, `PRE_EXISTING` when the same behavior and impact already exist on the target, and `HYPOTHETICAL` when the path is not demonstrated. State the baseline evidence briefly.
6. Keep pre-existing findings visible, but do not turn them into merge blockers unless the diff worsens them, the ticket explicitly owns them, or project policy requires all findings to close. Put them in residual risk as backlog or accepted with a concrete rationale. Never use `PRE_EXISTING` to excuse a changed capability, authorization boundary, data flow, or reachability.
7. Limit review expansion to the changed execution path and its direct callers. A repository-wide architecture or security audit is out of scope unless the diff changes that boundary. Group test-coverage gaps under their root defect instead of creating independent whack-a-mole findings.
8. Audit every new or changed test for vacuity. A test that cannot fail proves nothing and survives every later round, because each gate watches it pass. Check for a task cancelled before its first await, an event set but never awaited, an assertion on state the test itself assigned, and a `getattr(mod, "NAME", default)` whose default masks a rename. State explicitly which tests could pass while the behavior they name is broken. Group these under the root defect.
9. Maintain `assets/findings-ledger.schema.json`; orchestrator owns ledger.

Threat calibration for vetted internal/regulated systems:
- Weight up correctness, accidental tenant/data spillage, least privilege, secret hygiene, normal-operation exhaustion/availability, and control gaps.
- Weight hostile-repo/user chains Low unless accidentally reachable; then score accidental impact. Higher data sensitivity raises spillage/control impact, not hostile-user plausibility.
- Probe a hypothetical only to determine whether the changed diff makes it reachable. Stop after one bounded probe when it remains hypothetical.

## Output format

Parse the JSON first, then render:

```markdown
# Codex Review

Baseline: <ref> | Files reviewed: <n> | Standards file: <path or "none found">

## Findings

### Critical
- [fingerprint] [file:line] Finding. Evidence: EMPIRICALLY_VERIFIED | PROBED | HYPOTHETICAL. Scope: REGRESSION | NEWLY_REACHABLE | PRE_EXISTING | HYPOTHETICAL.
  Invariant: <violated invariant>. Path: <failing path>. Direction: <repair direction>. Proof test: <name>.

### High
- None

### Medium
- [fingerprint] [file:line] ... (same shape)

### Low
- [fingerprint] [file:line] ... (same shape)

## Blast radius
- Symbols checked: <list>. Affected untouched callers: <list or none>. Method: <codegraph explore | read-only method used>.

## Vacuous tests
- <test name> could pass while <named behavior> is broken. Grouped under <root fingerprint>.

## Residual risk
- [backlogged|accepted|monitor] <item> — <concrete rationale> <link if backlogged>

## Verification
- Commands run and results. Note any fallback used (no RTK, fresh scoped verification instead of resume, no standards file found).

## Gate Decision
PASS / BLOCKED
```

## Fix loop

Fresh round 1 reviews complete diff. Fixes use original Luna thread. Verify fixes by resuming original Sol with only ledger, prior findings, and changed hunks:

```bash
# Use only the session ID captured from this round-1 launch's authoritative
# output metadata. If it is absent or cannot be bound to this run, do not resume;
# use the fresh scoped-verification fallback below.
rtk proxy timeout 1800 codex exec resume "$SESSION_ID" -c sandbox_workspace_write.network_access=true -o "$OUT" \
  -m gpt-5.6-sol -c model_reasoning_effort=high \
  --output-schema "<skill-dir>/assets/review-verification-result.schema.json" \
  "Verify these fixes against your prior findings and the supplied ledger. Changed since your last review: <fix diff/hunks>. Re-check only your findings and the new hunks. Return JSON matching the supplied schema." \
  < /dev/null
```

Run affected checks during fixes; Sol may probe but not rerun full suite. Require new evidence to reopen resolved fingerprints and new probe to contradict empirical findings. If resume fails, use one fresh scoped verification.

When stable: orchestrator runs full relevant suite once, then fresh Sol reviews complete final diff with no ledger, old findings/verdicts, architect output, or clarification. Compare ledger only afterward. Any final-review code change stales suite evidence: focused checks -> full suite -> another fresh confirmation.

### One clarification

If finding cannot become bounded executor brief:

```bash
rtk proxy timeout 1800 codex exec resume "$SESSION_ID" \
  -c sandbox_workspace_write.network_access=true -o "$CLARIFY_OUT" \
  -m gpt-5.6-sol -c model_reasoning_effort=high \
  --output-schema "<skill-dir>/assets/review-clarification-result.schema.json" \
  "Clarify finding <fingerprint> only. State the violated invariant, failing path, repair direction, and named proof test. Do not write an executor brief, review unrelated code, or edit files." \
  < /dev/null
```

One clarification per family; further ambiguity triggers breaker.

### Circuit breaker

Trigger when same fingerprint/invariant survives two fixes, >=2 new findings share root cause, one clarification still lacks bounded repair/proof, or reviewer/executor evidence conflicts.

Packet only related fingerprints/evidence/invariants/direction, current hunks, CodeGraph seams, attempts/results, ledger entries, acceptance criteria, constraints, and boundaries. Record Git status/diff names, then:

```bash
rtk proxy timeout 1800 codex exec -p sol_max_fix_architect --strict-config \
  --add-dir "$HOME/.local/share/rtk" --skip-git-repo-check \
  --output-schema "<skill-dir>/assets/fix-architecture-result.schema.json" \
  -o "$ARCH_OUT" \
  "Read the compact repair evidence packet at <packet-path>. Diagnose the finding family and return a bounded repair contract. Review only: do not edit files, write an executor brief, approve the fix, or broaden into a full review." \
  < /dev/null
```

Run background; compare Git afterward. Any edit is protocol violation. Contract must name root cause, invariant, seams, repair, prohibited partial fixes, regressions, exact checks, risks, blockers. Claude verifies assumptions; `codex-implement` writes Luna brief. One architect per family; if blocked or repair misses same invariant, stop and replan/ask user.

## Schemas and gate

- Complete: `assets/review-result.schema.json`
- Clarification: `assets/review-clarification-result.schema.json`
- Verification: `assets/review-verification-result.schema.json`
- Ledger: `assets/findings-ledger.schema.json`
- Architect: `assets/fix-architecture-result.schema.json`

Parse JSON before rendering Markdown.

Critical/High blocks only when `EMPIRICALLY_VERIFIED` or `PROBED` and the finding is `REGRESSION` or `NEWLY_REACHABLE`; a pre-existing finding may still block when user/project policy or explicit ticket scope requires it. `HYPOTHETICAL` Critical/High gets one probe; still hypothetical becomes nonblocking residual risk. Medium/Low blocks only by user/project policy. Stop when acceptance criteria/tests pass, no verified Critical/High remains, and every Medium/Low is fixed, backlogged with link, or accepted with rationale. Never chase zero findings.

When review is part of an authorized implementation workflow, closure may update its plan checkbox/note, relevant `brief.md`, and `HANDOFF.md`. A standalone/review-only request returns findings and leaves repository files unchanged. Never expose secrets/controlled data. Remove temp review outputs unless user requests retention.
