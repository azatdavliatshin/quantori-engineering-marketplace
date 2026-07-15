---
description: Write tests for git changes that need them; diff-scoped judgment, delegates to /cover-with-tests.
argument-hint: [base-ref] (optional; defaults to uncommitted changes vs HEAD)
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, SlashCommand
---

# /test-changes

Cover *what just changed*: scope to the git diff, judge which changed files actually need tests, then cover each one. This is a **composition** atom — it makes two focused decisions (scope, needs-tests) and delegates the actual test-writing to `/cover-with-tests`, one target at a time. It never re-implements that command's logic.

**Base:** `$ARGUMENTS` — an optional base ref (e.g. `main`, `HEAD~3`). If empty, use uncommitted work vs `HEAD`.

## Step 1 — Scope: what changed

```bash
# uncommitted (default)
git diff --name-status HEAD
git ls-files --others --exclude-standard
# against a base ref (when $ARGUMENTS given)
git diff --name-status "$ARGUMENTS"...HEAD
```

Keep only added/modified `.ts`/`.tsx` files. Drop immediately: deleted files, test files themselves (`*.test.*`, `*.spec.*`, `__tests__/`), `.d.ts`, config files (`*.config.*`, `.*rc*`), generated/build output, and pure barrel files (re-exports only).

## Step 2 — Judge: which changes need tests

For each remaining file, read the actual diff (`git diff HEAD -- <file>` or `git diff "$ARGUMENTS"...HEAD -- <file>`), not just the file, and classify:

**Needs tests** when the change:
- adds or alters logic branches, conditions, or error handling;
- changes the observable behavior of an exported unit (return values, emitted effects, rendered output);
- is a bug fix — these need a **regression test** capturing the fixed behavior;
- introduces a new exported module/component with no corresponding test file.

**Skip (with stated reason)** when the change is:
- comments/docs, formatting, renames without behavior change;
- type-only (annotations, interfaces) with no runtime effect;
- already covered — a sibling test was updated in the same diff and exercises the changed behavior (verify by reading it, don't assume).

Output the judgment as a short table: file → needs-tests / skip → one-line reason. **If more than 5 files need tests, present the ranked list (highest-value first, per the conventions' priorities) and confirm scope with the user before generating.**

## Step 3 — Cover: delegate per file

For each file that needs tests, invoke `/cover-with-tests <file>` (via the SlashCommand tool when available; otherwise read `${CLAUDE_PLUGIN_ROOT}/commands/cover-with-tests.md` and follow its procedure exactly, with the file as target). That command owns detection, writing, running, and failure handling — including the never-weaken-a-test rule. For bug-fix files, tell it the diff context so the regression case is covered explicitly.

Process files one at a time; don't batch-write and run once at the end.

## Step 4 — Report

One summary across the whole run:
- files judged: covered / skipped (+ reasons);
- per covered file: test file written, cases, pass/fail;
- anything unverified (couldn't run) with the exact command to run it.

## Guardrails

- Scope is the diff. Never write tests for unchanged code, however tempting a gap looks — point the user to `/analyze-tests` instead.
- Every skip states its reason; silent skips are failures.
- All of `/cover-with-tests`' guardrails apply to the delegated work (no weakened assertions, no package installs, don't touch source under test).
