---
description: Review TypeScript code against the swappable standard; optionally fix via a capped subagent loop.
argument-hint: [path-or-glob] (optional, defaults to current git changes)
allowed-tools: Read, Grep, Glob, Bash, Edit, Task
---

# /review-code

Evaluate TypeScript code and report issues by severity. This is an **evaluate** atom (it judges, it doesn't generate). Its target is *code* — sibling atoms will cover other review targets (tests quality, folder structure, architecture) with their own rules files.

**Target:** `$ARGUMENTS` — a path or glob. If empty, review the current git changes:
```bash
git diff --name-only HEAD; git diff --stat HEAD
```
Review only changed `.ts`/`.tsx` files (and staged/untracked ones) when defaulting to the diff.

Load the backing skill **js-review** (severity discipline, stack detection, fix-loop machinery) and read the review standard at `${CLAUDE_PLUGIN_ROOT}/rules/code.md`. That file defines what gets flagged, so a standard swap changes the review automatically.

## Step 1 — Review (always)

Detect the stack first (see the backing skill) — `REACT=yes|no` gates the React areas of the standard.

Read the target files. Flag issues per the areas in `rules/code.md` (TypeScript, React when detected, Correctness, Tests if in scope, General), each tagged **[blocker] / [warning] / [nit]** per its severity definitions.

Output a structured report: grouped by file, each finding with severity, location, the problem, and the concrete fix. If clean, say so plainly. **Do not restate style a formatter/linter already enforces** unless it's a real correctness issue.

## Step 2 — Fix loop (only if the user asked to fix, or approves)

If the user asked `/review-code` to also fix (e.g. "review and fix"), run the **capped reviewer→fixer loop** from the backing skill: max **3** iterations, delegate findings to the **js-code-fixer** subagent, re-review touched files, stop on stall (see the skill for the full protocol), and verify with the project's tests when available.

Report each iteration briefly (what was fixed, what remains) and why the loop stopped. Never loop silently past the cap.

## Guardrails

- In review-only mode, change nothing.
- Be specific: every finding names a location and a fix. No vague "consider refactoring."
- Separate objective issues (bugs, type holes) from preference; mark preferences as **[nit]**.
- Don't let the fixer expand scope — fixes address flagged findings only.
