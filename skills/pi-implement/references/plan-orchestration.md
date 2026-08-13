# Pi plan orchestration

Use this reference when `pi-implement` receives `phase`, `all`, a plan-task name, or no argument while `implementation_plan.md` exists.

## 1. Select work

Read the plan in document order. Identify phase boundaries, unchecked tasks, completed prerequisites, dependencies, and explicit design gates.

For each selected slice record:

- stable slice ID and parent checkbox;
- acceptance clause;
- exact owned paths;
- dependencies and shared-state hazards;
- focused checks and behavioral evidence;
- mutation proof expected for new regression tests.

Unknown ownership creates a dependency edge. Group the graph into waves of no more than four ready slices.

## 2. Protect existing work

Record the user branch, baseline SHA, dirty paths, and current worktree inventory. Refuse to absorb unrelated changes. Confirm repository branch policy before non-trivial work on the default branch.

Managed Pi worktrees require a clean source state except for Pi-owned runtime artifacts. If the source is dirty, do not stash, reset, clean, or force isolation. Use one writer in the existing worktree when safe, or ask the user how to preserve the work.

## 3. Decide the write topology

Use one writer in the active worktree by default.

Use `worktree: true` only for concurrent slices with closed, disjoint ownership. Let Pi create and journal managed worktrees; do not recreate that lifecycle with raw `git worktree` commands. Each child handoff manifest is the authority for its patch, status, cleanup state, and recovery paths.

Managed worktrees start from tracked files. Before treating missing modules or generated inputs as defects, confirm dependencies were linked, installed, or provisioned by the project's approved setup hook. Put deterministic bootstrap requirements in every affected lane contract; do not copy untracked state ad hoc between worktrees.

Later dependency waves start from the integrated result of earlier waves, not the original baseline.

## 4. Dispatch

Launch a coordinated wave as one asynchronous `workflowScript` with stable lane keys. Each lane gets a distinct brief, file set, and expected output. Do not send clone prompts with only task IDs changed.

A blocked slice blocks its dependents but not independent completed slices. Retry a partial slice once only when the parent can tighten the same approved contract without inventing new scope.

## 5. Verify and integrate

For each completed slice in deterministic slice-ID order:

1. Open its handoff manifest and actual patch.
2. Compare changed paths with ownership.
3. Run focused checks and mutation proof independently.
4. Perform the parent hunk and standards pass.
5. Apply the verified patch to the integration worktree or branch.
6. Recheck the integrated diff before starting dependent work.

If integration conflicts, stop. The ownership or dependency graph was wrong. Do not hand-resolve the conflict and continue to describe the lanes as independent.

## 6. Gate the phase

After all required slices are integrated:

1. Run configured repository validation.
2. Run one complete `/skill:pi-review` discovery pass over baseline to integrated head. Parallel review angles may share the pass, but each must inspect the same complete diff from fresh context.
3. Synthesize accepted repairs into one writer contract.
4. Rerun affected checks after repair.
5. Resume retained reviewers only for their own fingerprints and fix hunks.
6. Trigger the review circuit breaker on repeated invariants or conflicting evidence.
7. Run final full validation and any policy-required fresh confirmation.

Only then mark parent checkboxes complete.

## 7. Publish the phase boundary

Before modifying the user branch, confirm its head and recorded dirty paths have not changed unexpectedly. Stage only exact phase paths and plan updates. Inspect the staged diff and rerun required checks in the publication worktree.

Use Conventional Commits when repository policy does not specify another convention. Separate structural and behavioral commits when required. Never push without authority.

## 8. Cleanup

Use handoff manifests and Pi managed-worktree cleanup state. Never remove a pre-existing worktree or branch. Never force removal merely to make cleanup look successful.

Retain and report any worktree when:

- its patch was not integrated and verified;
- it is dirty or divergent;
- publication evidence is incomplete;
- it predates this invocation;
- Pi reports partial cleanup or recovery instructions.

Use `worktree.discard` only for an explicitly abandoned managed handoff and only with the required user confirmation.
