---
description: Review TS/React code for best-practice issues; optionally fix via a capped subagent loop and re-check.
argument-hint: [path-or-glob] (optional, defaults to current git changes)
allowed-tools: Read, Grep, Glob, Bash, Edit, Task
---

# /review-code

Evaluate TS/React code and report issues by severity. This is an **evaluate** atom (it judges, it doesn't generate). It's a *general* reviewer — it already handles test files, so it deliberately isn't test-only, keeping its trigger distinct from `/cover-with-tests`.

**Target:** `$ARGUMENTS` — a path or glob. If empty, review the current git changes:
```bash
git diff --name-only HEAD; git diff --stat HEAD
```
Review only changed `.ts`/`.tsx` files (and staged/untracked ones) when defaulting to the diff.

Load the backing skill **js-test-authoring** and read `${CLAUDE_PLUGIN_ROOT}/rules/conventions.md`. Conventions there are the standard you review against, so a convention swap changes the review automatically.

## Step 1 — Review (always)

Read the target files. Flag issues in these areas, each tagged **[blocker] / [warning] / [nit]**:

- **TypeScript:** `any` or unsafe casts, missing/loose types on public surfaces, non-null assertions hiding real nullability, unhandled `Promise`/floating async.
- **React:** missing/incorrect hook deps, state derivable from props, keys on lists, effects that should be event handlers, unnecessary re-renders, unstable callbacks passed to memoized children, direct DOM access.
- **Correctness:** unhandled error/empty/loading states, off-by-one/boundary bugs, race conditions, resource leaks (listeners, timers, subscriptions).
- **Tests (if present):** implementation-detail assertions, `data-testid` where a role/label query fits, missing branch coverage, brittle snapshots.
- **General:** dead code, misleading names, duplicated logic, security foot-guns (unsanitized `dangerouslySetInnerHTML`, secrets in code).

Output a structured report: grouped by file, each finding with severity, location, the problem, and the concrete fix. If clean, say so plainly. **Do not restate style a formatter/linter already enforces** unless it's a real correctness issue.

## Step 2 — Fix loop (only if the user asked to fix, or approves)

If the user asked `/review-code` to also fix (e.g. "review and fix"), run a **capped reviewer→fixer loop** (borrowed GSD pattern), max **3** iterations:

1. Collect the current **[blocker]** and agreed **[warning]** findings.
2. Delegate them to the **fixer subagent** (Task tool, `subagent_type: general-purpose`, or the bundled `js-code-fixer` agent if available). Hand it: the file list, the specific findings, and a strict instruction to fix *only* those and change nothing else.
3. **Re-review** the touched files (repeat Step 1 on them only).
4. **Stall detection — stop early when any holds:**
   - no blockers/warnings remain, **or**
   - a fixer pass resolved nothing new (the finding set didn't shrink), **or**
   - a fix introduced a regression the next pass flags, **or**
   - 3 iterations reached.
5. **Verify:** if the project has a test script and tests touch the changed files, run them (see the backing skill) to confirm fixes didn't break anything.

Report each iteration briefly (what was fixed, what remains) and why the loop stopped. Never loop silently past the cap.

## Guardrails

- In review-only mode, change nothing.
- Be specific: every finding names a location and a fix. No vague "consider refactoring."
- Separate objective issues (bugs, type holes) from preference; mark preferences as **[nit]**.
- Don't let the fixer expand scope — fixes address flagged findings only.
