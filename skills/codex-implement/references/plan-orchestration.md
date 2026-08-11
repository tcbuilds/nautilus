# Plan orchestration

Use this workflow when `codex-implement` receives `phase`, `all`, a plan-task
name, or no argument while `implementation_plan.md` exists.

## 1. Select and slice work

Read the plan in document order. Identify phase boundaries, unchecked tasks,
completed prerequisites, and explicit dependencies.

Turn selected work into thin slices before launching Luna. A useful slice:

- owns one acceptance clause;
- normally changes one to four files;
- has one closed editable path set;
- has one focused verification command;
- fits one executor budget;
- can be integrated without a second slice editing the same path.

Split a large checkbox when its acceptance clauses and files are independently
implementable. Keep the parent checkbox open until every child slice closes.

Record for every slice:

- stable slice ID and parent checkbox;
- exact owned paths;
- dependencies;
- focused gates;
- required mutation evidence;
- acceptance evidence expected.

Unknown ownership creates a dependency edge. Shared files, generated outputs,
migrations, manifests, lockfiles, and shared test fixtures cannot appear in two
concurrent slices. Never infer disjointness from intent alone.

Group the dependency graph into waves. Run at most four slices in one wave.

## 2. Protect existing work

Before creating worktrees:

1. Record the user branch and `BASE_SHA`.
2. Record every pre-existing dirty path and whether it belongs to this phase.
3. Refuse to mix unrelated dirty paths into the phase.
4. Confirm branch policy before non-trivial work on `main` or `master`.

Codex state artifacts do not justify changing `.gitignore`. Repositories may
intentionally track `.codex/` harness configuration.

## 3. Create isolated worktrees

Create one phase integration worktree and one worktree for each ready slice:

```bash
git worktree add -b "codex-implement/<phase-id>" \
  "<phase-worktree>" "$BASE_SHA"

git worktree add -b "codex-implement/<phase-id>/<slice-id>" \
  "<slice-worktree>" "codex-implement/<phase-id>"
```

Use collision-safe IDs and new paths. Never launch two executors in one
worktree. Each later dependency wave branches from the updated phase branch.

## 4. Brief each slice

Apply the main skill's Brief contract. Add these exact fields:

```text
# Slice identity
Phase: <phase>
Parent task: <plan checkbox>
Slice: <slice ID>
Worktree: <absolute slice worktree>

# Closed file ownership
You may edit only:
<exact paths>

Any required change outside this list is BLOCKED. Do not edit it.

# Dependencies already integrated
<slice IDs and behavior now available>

# Focused gates
<exact commands>

# Mutation proof
<mutation -> test that must fail>
```

Resolve every placeholder before launch. Name files held by concurrent lanes in
the do-not-touch list.

## 5. Dispatch waves

Launch every ready slice in one wave without waiting for the previous launch to
finish. Each uses `luna_max_executor`, its own output path, and its own worktree.

Wait for the whole wave. A blocked slice blocks its dependents but does not
invalidate independent completed slices. Retry a partial result once with a
tighter brief in the same slice worktree.

Do not run `codex-review` for a slice.

## 6. Verify and integrate slices

For each completed slice, in deterministic slice-ID order:

1. Compare actual changed paths with its closed ownership set.
2. Independently run every focused gate and mutation.
3. Perform the main skill's round-0 hunk and standards pass.
4. Stage only owned paths and create a temporary slice commit.
5. Cherry-pick the temporary commit into the phase integration worktree.

Never push slice branches. A cherry-pick conflict means the ownership graph was
wrong. Abort that integration attempt, repair the dependency graph, and rerun
the affected slice from the updated phase head. Do not hand-resolve a conflict
and pretend the slices were independent.

## 7. Gate and review the phase

After every required slice is integrated:

1. Run every configured repository validation command in the phase worktree.
2. Start one fresh Sol review over `BASE_SHA..HEAD`.
3. Fix Critical/High findings through bounded Luna-max repair worktrees.
4. Rerun all configured gates after each integrated repair.
5. Resume the same Sol reviewer only to verify its findings.
6. Stop after two failed fix/verification cycles and surface the blocker.
7. Dispose Medium/Low findings under project policy.

There is no per-slice Sol review and no second fresh full-phase review. One
reviewer holds the integrated phase; finding-verification resumes that session.

Only after this gate closes, mark fully satisfied parent checkboxes complete.
Commit the plan-only update temporarily on the phase branch so squash integration
cannot omit it.

## 8. Publish the phase boundary

Before touching the user branch, require its `HEAD` still equals `BASE_SHA` and
its recorded dirty paths are unchanged. If it moved, stop and reintegrate
deliberately.

Squash the temporary phase branch:

```bash
git merge --squash "codex-implement/<phase-id>"
git add <exact-phase-paths> implementation_plan.md
```

Require `git diff --cached --name-only` to match the exact phase paths plus the
plan. Inspect the staged diff and rerun required gates in the user worktree.

Create one Conventional Commit under 72 characters with no AI attribution.
When a phase contains both structural and behavioral work, create separate
phase-boundary commits rather than mixing them. Push only when user or repository
policy authorizes it.

## 9. Cleanup

Remove temporary worktrees and branches only after:

- the public phase commit exists;
- any authorized push is confirmed;
- every temporary worktree is clean;
- no recorded user work would be removed.

Keep diagnostic output only when a failed lane needs recovery. Otherwise remove
temporary briefs and schemas; retain the small per-worktree final result until
the phase report is complete.
