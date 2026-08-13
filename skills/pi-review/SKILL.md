---
name: pi-review
description: Run an independent Pi-native review over changed files using fresh-context reviewer subagents, evidence-backed severity findings, parent synthesis, retained-run fix verification, and an oracle circuit breaker for repeated invariants. Use after implementation, before completion or merge, or when a skeptical cross-family review is needed.
compatibility: Requires Pi with pi-subagents 0.46.0 or newer and an executable reviewer agent.
---

# Pi Review

Review the task-relevant diff without editing it. The parent defines scope, launches independent reviewers, verifies evidence, owns the findings ledger, and decides the gate. Do not shell out to Codex, Claude Code, or another agent CLI.

## Usage

```text
/skill:pi-review                    # current task-relevant diff
/skill:pi-review <baseline>         # baseline to HEAD
/skill:pi-review <files-or-scope>   # explicit review scope
```

A standalone review leaves project files unchanged. When review is part of an authorized implementation workflow, a later single writer may apply parent-approved fixes.

## Preflight and scope

1. Require `pi-subagents >=0.46.0`; if the installed version cannot be verified, report the unverified preflight rather than assuming retained-resume behavior.
2. Run `subagent({ action: "list" })`; use only executable, non-disabled reviewers.
3. Derive tracked and untracked scoped files from user input and Git state. Never review the whole repository when the task owns a narrower diff.
4. Establish the target baseline and compare every candidate finding against it.
5. Read repository instructions and matching path-scoped rules. If no applicable standards resolve, record that fact rather than fabricating a path.
6. Inspect callers of changed public symbols with the repository's structural index when available; otherwise use bounded read-only search.
7. Record the validation contract and acceptance criteria the change claims to satisfy.
8. Materialize a read-only review packet outside the repository containing the scoped patch, baseline excerpts needed for comparison, changed/untracked file list, validation contract, matching standards, and the full finding contract below. Verify the packet contains no secrets or unrelated controlled data.

Preserve unrelated changes. Reviewer children are read-only: no project/source edits, commits, pushes, comments, merges, releases, or publication.

## Review angles

Use one reviewer for a small, low-risk diff. For broad, risky, security-sensitive, or user-visible changes, launch fresh-context reviewers in parallel with distinct prompts. Typical angles:

- correctness, regressions, concurrency, and failure behavior;
- tests, mutation strength, and validation gaps;
- security, privacy, data handling, and least privilege;
- performance, resource bounds, and availability;
- API, migration, documentation, or user-flow contracts;
- simplicity and maintainability when complexity itself creates risk.

Every reviewer reads the same verified review packet and then inspects scoped project files directly. Pi's builtin reviewer has read/search tools but no shell, so a bare Git ref is not sufficient evidence. The parent runs Git commands and safe probes, materializes their output, and remains responsible for validating baseline and runtime claims. Do not provide another reviewer's verdict or repair advice during discovery.

Prefer a reviewer from a different model family or provider than the implementer when an allowed capable model is available. Cross-family review is a quality option, not a reason to bypass model scope, data policy, availability, or cost constraints. Inspect the live agent/model mapping before overriding defaults; never hardcode a model that may not exist. Record the implementer and reviewer families. If policy requires cross-family independence and none is available, block or obtain an explicit waiver; otherwise record the same-family limitation as residual risk.

## Launch

Before launch, write the shared packet to a readable absolute path such as `<scratch>/pi-review-packet.md`. The packet carries the complete finding contract, so every fresh reviewer receives the same schema without inheriting this skill.

```javascript
subagent({
  workflowScript: `return runs.all([
    {
      key: "correctness",
      agent: "reviewer",
      task: "Read <packet-path>, then review its scoped change for correctness and regressions. Inspect named project files directly. Do not edit files. Return only findings matching the packet contract."
    },
    {
      key: "tests",
      agent: "reviewer",
      task: "Read <packet-path>, then review its scoped tests for vacuity, mutation strength, and validation gaps. Inspect named project files directly. Do not edit files. Return only findings matching the packet contract."
    },
    {
      key: "security",
      agent: "reviewer",
      task: "Read <packet-path>, then review its scoped change for security, privacy, data handling, least privilege, and resource bounds. Inspect named project files directly. Do not edit files. Return only findings matching the packet contract."
    }
  ])`,
  context: "fresh",
  async: true
})
```

Resolve `<packet-path>` before launch. Use fewer lanes when angles would duplicate one another. Keep run IDs from the returned results so the same reviewers can verify their findings later. Retained resume is for reviewers reading a stable integration checkout; do not promise resume into a managed writer worktree that Pi may already have cleaned up. Repairs use a new worker run or managed worktree. Use durable artifacts for large reports; otherwise inline output is sufficient.

## Finding contract

Require findings in severity order. Each finding includes:

- stable fingerprint;
- severity: Critical, High, Medium, or Low;
- `file:line` or the narrowest available location;
- evidence class: `EMPIRICALLY_VERIFIED`, `PROBED`, or `HYPOTHETICAL`;
- scope status: `REGRESSION`, `NEWLY_REACHABLE`, `PRE_EXISTING`, or `HYPOTHETICAL`;
- baseline comparison;
- violated invariant;
- failing execution path or trigger;
- concise evidence;
- repair direction, not an executor brief;
- named proof test or check.

Reject style-only preferences without a repository rule or concrete maintenance risk. Group test gaps beneath their root defect instead of multiplying findings.

### Evidence and scope

- `EMPIRICALLY_VERIFIED`: the parent reproduced the failure or observed the changed execution path fail with direct runtime evidence.
- `PROBED`: a bounded parent-run experiment or decisive source/baseline comparison demonstrates reachability, but not a complete production reproduction.
- `HYPOTHETICAL`: plausible from inspection, but reachability or impact remains unproven.
- `REGRESSION`: the diff introduces the defect.
- `NEWLY_REACHABLE`: the diff materially expands reachability or impact.
- `PRE_EXISTING`: equivalent behavior and impact exist at baseline.
- `HYPOTHETICAL`: the path is not demonstrated.

Keep pre-existing findings visible as residual risk, but do not block on them unless the change worsens them, the task owns them, or project policy requires closure. Never label a changed authorization boundary, capability, data flow, or reachability as pre-existing merely because adjacent code already existed.

Probe a hypothetical Critical/High once when a bounded safe probe can determine reachability. If it remains hypothetical, record nonblocking residual risk rather than inflating certainty.

## Test-vacuity audit

Review every new or changed test for whether it can fail when the named behavior breaks. Check especially for:

- async work cancelled before its first execution point;
- events or futures set but never awaited;
- assertions on state assigned directly by the test;
- defaults that mask missing or renamed symbols;
- mocks that bypass the changed seam;
- mutation patches that match no unique source location.

Name the exact test and broken behavior. When practical, the parent independently applies the smallest reversible mutation and confirms the test fails.

## Parent synthesis

The parent deduplicates fingerprints and classifies output as:

1. blockers;
2. fixes worth doing now;
3. residual risks requiring backlog or acceptance;
4. optional or unsupported feedback to ignore.

Reviewer output is evidence, not authority. Verify file locations, baseline claims, execution paths, and repair assumptions before briefing a writer. Do not forward raw findings as an implementation prompt.

For multi-round reviews, maintain a parent-owned ledger matching `assets/findings-ledger.schema.json`. Store the latest retained reviewer run ID with each fingerprint. Keep full reports in artifacts rather than mission state; mission state should contain only compact IDs, dispositions, and artifact paths.

Render the result:

```markdown
# Pi Review

Baseline: <ref> | Files reviewed: <n> | Standards: <paths or none found>

## Findings
### Critical
- [fingerprint] [file:line] Finding. Evidence: <class>. Scope: <status>.
  Invariant: <invariant>. Path: <path>. Direction: <direction>. Proof: <test>.

### High
- None

### Medium
- None

### Low
- None

## Blast radius
- Symbols checked: <list>. Affected untouched callers: <list or none>. Method: <method>.

## Vacuous tests
- <test and broken behavior, or none>

## Residual risk
- [backlogged|accepted|monitor] <item and rationale>

## Verification
- <commands, probes, and fallbacks>

## Gate Decision
PASS / BLOCKED
```

## Fix verification

When implementation is authorized, send the parent's bounded synthesis to one writer. After fixes and focused checks, resume only the reviewer that owns each fingerprint:

```javascript
subagent({
  workflowScript: `return runs.run("verify-correctness", {
    resume: "<latest-reviewer-run-id>",
    task: "Verify only fingerprints <ids> against these exact fix hunks: <hunks>. Re-check the named invariant and proof tests. Do not edit files or broaden review."
  })`,
  async: true
})
```

Every resume returns a new run ID; retain and use the latest ID. If a retained run cannot be resumed, use one fresh scoped verification and record the fallback. A child-reported test result does not replace parent validation.

After fixes stabilize, run the complete affected validation. Any later code change makes that evidence stale. For high-risk changes or project policy, run a fresh final review over the complete final diff without prior findings, ledger, verdict, or architect advice.

## Circuit breaker

Trigger when:

- the same fingerprint or invariant survives two fixes;
- two or more new findings share a root cause;
- one clarification still cannot produce a bounded repair and proof;
- reviewer and executor evidence conflict.

Launch one advisory `oracle` with only the related evidence, current hunks, verified seams, attempts, constraints, and acceptance criteria. The oracle diagnoses root cause and returns a repair contract; it does not edit, approve, broaden scope, or write the final worker brief. The parent verifies the contract and decides whether to replan, brief one writer, or ask the user.

Use a different capable model family for the oracle when allowed and useful. One architect per finding family. If the repair misses the same invariant, stop instead of escalating an endless agent loop.

## Gate

Critical/High blocks only when `EMPIRICALLY_VERIFIED` or `PROBED` and `REGRESSION` or `NEWLY_REACHABLE`, unless project policy is stricter. Hypothetical Critical/High gets one bounded probe and then becomes residual risk if still unproven. Medium/Low blocks only under user or project policy.

Pass when acceptance criteria and validation pass, no blocking finding remains, and every Medium/Low item is fixed, backlogged with a link, or accepted with rationale. Do not chase a zero-finding stamp.

Remove temporary reports unless retention was requested. Never expose secrets, controlled data, private prompts, or unrelated repository content in reviewer tasks or artifacts.
